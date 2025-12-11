require 'rails_helper'
require 'stringio'

RSpec.describe "Listings", type: :request do
  let(:user) do
    User.create!(
      email: 'profile@example.com',
      password: 'password123',
      display_name: 'Initial Name',
      bio: 'Initial bio'
    )
  end

  let(:other_user) do
    User.create!(
      email: 'otheruser@example.com',
      password: 'password123',
      display_name: 'Other User',
      bio: 'Other bio'
    )
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  def attach_image_to(listing, filename: 'photo.png', content_type: 'image/png', content: 'image-data')
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(content),
      filename: filename,
      content_type: content_type
    )
    listing.images.attach(blob)
    listing.images.last
  end

  def build_upload(content:, content_type:, filename: 'upload.png')
    file = Tempfile.new(['upload', File.extname(filename)])
    file.write(content)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, content_type)
  end


  # ========================================
  # CREATE LISTING FEATURE
  # ========================================
  
  describe "GET /listings/new" do
    it "renders the new listing form" do
      
      get new_listing_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('New Listing')
    end
  end

  describe "POST /listings" do
    context "with valid parameters" do
      let(:valid_attributes) do
        {
          listing: {
            title: 'Cozy room near campus',
            description: 'Small furnished room, utilities included',
            price: 600,
            city: 'New York'
          }
        }
      end

      it "creates a new listing" do
        expect {
          post listings_path, params: valid_attributes
        }.to change(Listing, :count).by(1)
      end

      it "associates the listing with the current user" do
        post listings_path, params: valid_attributes
        
        listing = Listing.last
        expect(listing.user).to eq(user)
      end

      it "sets the status to pending" do
        post listings_path, params: valid_attributes
        
        listing = Listing.last
        expect(listing.status).to eq(Listing::STATUS_PENDING)
      end

      it "sets the owner_email to current user's email" do
        post listings_path, params: valid_attributes
        
        listing = Listing.last
        expect(listing.owner_email).to eq(user.email)
      end

      it "redirects to the listing page" do
        post listings_path, params: valid_attributes
        
        expect(response).to redirect_to(listing_path(Listing.last))
      end

      it "displays a success message" do
        post listings_path, params: valid_attributes
        
        follow_redirect!
        expect(response.body).to include('Listing was successfully created')
      end
    end

    context "with invalid parameters (missing title)" do
      let(:invalid_attributes) do
        {
          listing: {
            title: '',
            description: 'No title provided',
            price: 500,
            city: 'Boston'
          }
        }
      end

      it "does not create a new listing" do
        expect {
          post listings_path, params: invalid_attributes
        }.not_to change(Listing, :count)
      end

      it "renders the new template with unprocessable entity status" do
        post listings_path, params: invalid_attributes
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "displays validation error for title" do
        post listings_path, params: invalid_attributes
        
        expect(response.body).to include("can&#39;t be blank")
      end
    end

    context "with invalid parameters (missing price)" do
      let(:invalid_attributes) do
        {
          listing: {
            title: 'Affordable studio',
            description: 'Cozy studio near downtown',
            price: nil,
            city: 'Chicago'
          }
        }
      end

      it "does not create a new listing" do
        expect {
          post listings_path, params: invalid_attributes
        }.not_to change(Listing, :count)
      end

      it "displays price validation error" do
        post listings_path, params: invalid_attributes
        
        expect(response.body).to include("can&#39;t be blank")
      end
    end

    context "with invalid parameters (negative price)" do
      let(:invalid_attributes) do
        {
          listing: {
            title: 'Budget room',
            description: 'Cheap room for students',
            price: -100,
            city: 'San Francisco'
          }
        }
      end

      it "does not create a new listing" do
        expect {
          post listings_path, params: invalid_attributes
        }.not_to change(Listing, :count)
      end

      it "displays price validation error" do
        post listings_path, params: invalid_attributes
        
        expect(response.body).to include("must be greater than 0")
      end
    end
  end

  # ========================================
  # MANAGE LISTING FEATURE
  # ========================================

  let(:listing) do
    Listing.create!(
      title: 'Cozy Studio Apartment',
      description: 'Small but functional',
      price: 800,
      city: 'New York',
      status: Listing::STATUS_PENDING,
      owner_email: user.email,
      user: user
    )
  end

  let(:other_listing) do
    Listing.create!(
      title: 'Luxury Loft Midtown',
      description: 'High-end apartment',
      price: 2500,
      city: 'New York',
      status: Listing::STATUS_PENDING,
      owner_email: other_user.email,
      user: other_user
    )
  end

  describe "GET /listings/:id" do
    it "displays the listing details" do
      get listing_path(listing)
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(listing.title)
      expect(response.body).to include(listing.description)
      expect(response.body).to include(listing.price.to_s)
      expect(response.body).to include(listing.city)
    end

    it "displays updated listing details after update" do
      listing.update!(
        description: 'Recently renovated and near NYU campus.',
        price: 950
      )
      
      get listing_path(listing)
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Recently renovated and near NYU campus.')
      expect(response.body).to include('950')
    end
  end

  describe "GET /listings/:id/edit" do
    context "when editing own listing" do
      it "renders the edit form" do
        get edit_listing_path(listing)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Edit Listing')
      end

      it "pre-fills the form with current listing data" do
        get edit_listing_path(listing)
        
        expect(response.body).to include(listing.title)
        expect(response.body).to include(listing.description)
        expect(response.body).to include(listing.price.to_s)
      end
    end
  end

  describe "PATCH /listings/:id" do
    context "with valid parameters" do
      let(:valid_update_params) do
        {
          listing: {
            description: 'Recently renovated and near NYU campus.',
            price: 950
          }
        }
      end

      it "updates the listing attributes" do
        patch listing_path(listing), params: valid_update_params
        
        listing.reload
        expect(listing.description).to eq('Recently renovated and near NYU campus.')
        expect(listing.price).to eq(950)
      end

      it "redirects to the listing page" do
        patch listing_path(listing), params: valid_update_params
        
        expect(response).to redirect_to(listing_path(listing))
      end

      it "displays a success message" do
        patch listing_path(listing), params: valid_update_params
        
        follow_redirect!
        expect(response.body).to include('Listing was successfully updated')
      end

      it "updates only the specified fields" do
        original_title = listing.title
        original_city = listing.city
        
        patch listing_path(listing), params: valid_update_params
        
        listing.reload
        expect(listing.title).to eq(original_title)
        expect(listing.city).to eq(original_city)
      end
    end

    context "when adding additional images" do
      it "appends new images without removing existing ones" do
        existing_image = attach_image_to(listing, filename: 'existing.png')
        new_image = fixture_file_upload(
          Rails.root.join('features', 'screenshots', 'user_profile_management_1.png'),
          'image/png'
        )

        patch listing_path(listing), params: { listing: { images: [new_image] } }

        listing.reload
        filenames = listing.images.map { |img| img.filename.to_s }

        expect(filenames).to include(existing_image.filename.to_s)
        expect(filenames).to include(new_image.original_filename)
        expect(listing.images.count).to eq(2)
      end
    end

    context "when already at the image limit" do
      before do
        Listing::MAX_IMAGES.times do |idx|
          attach_image_to(listing, filename: "img-#{idx}.png")
        end
      end

      it "rejects new images and does not persist attachments" do
        extra_image = build_upload(content: 'extra', content_type: 'image/png', filename: 'extra.png')

        expect {
          patch listing_path(listing), params: { listing: { images: [extra_image] } }
        }.not_to change { listing.reload.images.count }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("cannot exceed #{Listing::MAX_IMAGES} images")
      end
    end

    context "when adding invalid image types" do
      it "does not persist invalid attachments" do
        bad_image = build_upload(content: 'text-data', content_type: 'text/plain', filename: 'bad.txt')

        expect {
          patch listing_path(listing), params: { listing: { images: [bad_image] } }
        }.not_to change { listing.reload.images.count }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("must be JPEG, PNG, WebP, or GIF")
      end
    end

    context "when adding oversized images" do
      it "rejects images exceeding size limit" do
        large_content = 'a' * (Listing::MAX_IMAGE_SIZE + 1)
        large_image = build_upload(content: large_content, content_type: 'image/png', filename: 'large.png')

        expect {
          patch listing_path(listing), params: { listing: { images: [large_image] } }
        }.not_to change { listing.reload.images.count }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("must be less than #{Listing::MAX_IMAGE_SIZE / 1.megabyte}MB each")
      end
    end

    context "when other validations fail with new images" do
      it "rolls back image attachments on validation errors" do
        existing_image = attach_image_to(listing, filename: 'existing.png')
        new_image = build_upload(content: 'new', content_type: 'image/png', filename: 'new.png')

        expect {
          patch listing_path(listing), params: { listing: { title: '', images: [new_image] } }
        }.not_to change { listing.reload.images.count }

        expect(listing.images.first.filename.to_s).to eq(existing_image.filename.to_s)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("can&#39;t be blank")
      end
    end

    context "with invalid parameters (blank title)" do
      let(:invalid_params) do
        {
          listing: {
            title: ''
          }
        }
      end

      it "renders the edit template with unprocessable entity status" do
        patch listing_path(listing), params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "displays validation errors" do
        patch listing_path(listing), params: invalid_params
        
        expect(response.body).to include("can&#39;t be blank")
      end
    end

    context "with invalid parameters (negative price)" do
      let(:invalid_params) do
        {
          listing: {
            price: -1000
          }
        }
      end

      it "does not update the listing" do
        original_price = listing.price
        
        patch listing_path(listing), params: invalid_params
        
        listing.reload
        expect(listing.price).to eq(original_price)
      end

      it "displays price validation error" do
        patch listing_path(listing), params: invalid_params
        
        expect(response.body).to include('must be greater than 0')
      end
    end

    context "with multiple invalid parameters" do
      let(:invalid_params) do
        {
          listing: {
            title: '',
            price: -1000
          }
        }
      end

      it "preserves all original values" do
        original_title = listing.title
        original_price = listing.price
        
        patch listing_path(listing), params: invalid_params
        
        listing.reload
        expect(listing.title).to eq(original_title)
        expect(listing.price).to eq(original_price)
      end

      it "displays multiple validation errors" do
        patch listing_path(listing), params: invalid_params
        
        expect(response.body).to include("can&#39;t be blank")
        expect(response.body).to include('must be greater than 0')
      end
    end

  end

  describe "GET /listings/:id/edit as non-owner" do
    it "redirects unauthorized users" do
      get edit_listing_path(other_listing)

      expect(response).to redirect_to(listings_path)
      follow_redirect!
      expect(response.body).to include('You are not authorized to perform this action.')
    end
  end

  describe "DELETE /listings/:id" do
    context "when deleting own listing" do
      it "deletes the listing from the database" do
        # Create the listing first to ensure it exists
        listing_to_delete = listing
        
        expect {
          delete listing_path(listing_to_delete)
        }.to change(Listing, :count).by(-1)
      end

      it "removes the listing from the database" do
        listing_id = listing.id
        delete listing_path(listing)
        
        expect(Listing.find_by(id: listing_id)).to be_nil
      end

      it "redirects to listings index" do
        delete listing_path(listing)
        
        expect(response).to redirect_to(listings_path)
      end
    end
  end

  describe "GET /listings" do
    before do
      listing # Create the listing
      other_listing # Create other user's listing
    end

    it "displays all listings" do
      get listings_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include(listing.title)
      expect(response.body).to include(other_listing.title)
    end

    it "does not display deleted listings" do
      deleted_title = listing.title
      listing.destroy
      
      get listings_path
      
      expect(response.body).not_to include(deleted_title)
    end
  end

  describe "GET /users/:id/listings" do
    it "shows only listings for the specified user" do
      listing
      other_listing

      get user_listings_path(user)

      expect(response).to have_http_status(:success)
      expect(response.body).to include(listing.title)
      expect(response.body).not_to include(other_listing.title)
    end
  end

  describe "GET /listings/search.json" do
    it "returns filtered listings as JSON" do
      listing
      other_listing
      Listing.create!(
        title: 'Outside city',
        description: 'Should not be returned',
        price: 500,
        city: 'Boston',
        status: Listing::STATUS_PENDING,
        owner_email: other_user.email,
        user: other_user
      )

      get search_listings_path, params: { city: 'New York' }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      cities = body.map { |row| row['city'] }
      expect(cities).to all(match(/new york/i))
      expect(cities).not_to include('Boston')
    end
  end

  describe "DELETE /listings/:id/images/:image_id" do
    let!(:image) { attach_image_to(listing) }

    it "removes the image and clears the primary pointer" do
      listing.update!(primary_image_id: image.id)

      expect {
        delete remove_image_listing_path(listing, image_id: image.id)
      }.to change { listing.reload.images.attached? }.from(true).to(false)

      expect(response).to redirect_to(edit_listing_path(listing))
      expect(flash[:notice]).to eq('Image was successfully removed.')
      expect(listing.reload.primary_image_id).to be_nil
    end

    it "gracefully handles missing images" do
      delete remove_image_listing_path(listing, image_id: 'missing')

      expect(response).to redirect_to(edit_listing_path(listing))
      follow_redirect!
      expect(response.body).to include('Image not found.')
    end
  end

  describe "PATCH /listings/:id/images/:image_id/set_primary" do
    let!(:image) { attach_image_to(listing) }

    it "sets the primary image" do
      patch set_primary_image_listing_path(listing, image_id: image.id)

      expect(response).to redirect_to(edit_listing_path(listing))
      expect(listing.reload.primary_image_id).to eq(image.id.to_s)
    end

    it "handles missing images" do
      patch set_primary_image_listing_path(listing, image_id: 'missing')

      expect(response).to redirect_to(edit_listing_path(listing))
      follow_redirect!
      expect(response.body).to include('Image not found.')
    end
  end
end