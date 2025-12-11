require 'rails_helper'
require 'securerandom'
require 'stringio'

RSpec.describe Listing, type: :model do
  describe '.search' do
    before do
      Listing.delete_all
      User.delete_all
    end

    def listing_attributes(user, overrides = {})
      {
        title: 'Listing',
        description: 'Default description',
        price: 500,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      }.merge(overrides)
    end

    it 'returns all listings when no filters are provided' do
      user = User.create!(email: 'searcher@example.com', password: 'password123')
      listings = [
        Listing.create!(listing_attributes(user, title: 'Cozy room', description: 'Near campus', price: 600, city: 'New York')),
        Listing.create!(listing_attributes(user, title: 'Downtown studio', description: 'Close to subway', price: 1200, city: 'Boston'))
      ]

      results = described_class.search({})

      expect(results).to match_array(listings)
    end

    it 'filters listings by city case-insensitively' do
      user = User.create!(email: 'filtered@example.com', password: 'password123')
      matching = Listing.create!(listing_attributes(user, title: 'Harlem apartment', description: 'Spacious', price: 900, city: 'New York'))
      Listing.create!(listing_attributes(user, title: 'Downtown loft', description: 'Trendy', price: 1500, city: 'Chicago'))

      results = described_class.search(city: 'new york')

      expect(results).to contain_exactly(matching)
    end

    it 'filters listings within a price range inclusive of bounds' do
      user = User.create!(email: 'pricing@example.com', password: 'password123')
      in_range = [
        Listing.create!(listing_attributes(user, title: 'Cozy room', description: 'Affordable', price: 600, city: 'Boston')),
        Listing.create!(listing_attributes(user, title: 'Sunny studio', description: 'Bright', price: 900, city: 'Boston'))
      ]
      Listing.create!(listing_attributes(user, title: 'Budget basement', description: 'Cheap', price: 500, city: 'Boston'))
      Listing.create!(listing_attributes(user, title: 'Luxury loft', description: 'Expensive', price: 1200, city: 'Boston'))

      results = described_class.search(min_price: 600, max_price: 900)

      expect(results).to match_array(in_range)
    end

    it 'filters listings by keywords in title or description' do
      user = User.create!(email: 'keywords@example.com', password: 'password123')
      matching = [
        Listing.create!(listing_attributes(user, title: 'Furnished studio', description: 'Close to campus', price: 800, city: 'Boston')),
        Listing.create!(listing_attributes(user, title: 'Sunny loft', description: 'Furnished with modern decor', price: 1100, city: 'Boston'))
      ]
      Listing.create!(listing_attributes(user, title: 'Budget room', description: 'Shared space', price: 500, city: 'Boston'))

      results = described_class.search(keywords: 'furnished')

      expect(results).to match_array(matching)
    end

    it 'applies multiple filters together' do
      user = User.create!(email: 'combined@example.com', password: 'password123')
      matching = Listing.create!(
        listing_attributes(
          user,
          title: 'Furnished Midtown studio',
          description: 'Modern furnished space',
          price: 850,
          city: 'New York'
        )
      )
      Listing.create!(listing_attributes(user, title: 'Furnished but pricey', description: 'Luxury', price: 1500, city: 'New York'))
      Listing.create!(listing_attributes(user, title: 'Affordable unfurnished', description: 'Basic room', price: 700, city: 'New York'))
      Listing.create!(listing_attributes(user, title: 'Furnished in Boston', description: 'Nice place', price: 850, city: 'Boston'))

      results = described_class.search(city: 'new york', min_price: 800, max_price: 900, keywords: 'furnished')

      expect(results).to contain_exactly(matching)
    end
  end

  describe 'validations' do
    let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

    it 'is invalid without a title' do
      listing = Listing.new(
        price: 600,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a price' do
      listing = Listing.new(
        title: 'Cozy room',
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:price]).to include("can't be blank")
    end

    it 'is invalid with a negative price' do
      listing = Listing.new(
        title: 'Budget room',
        price: -100,
        city: 'San Francisco',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:price]).to include("must be greater than 0")
    end

    it 'is invalid with a zero price' do
      listing = Listing.new(
        title: 'Free room',
        price: 0,
        city: 'Boston',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:price]).to include("must be greater than 0")
    end

    it 'is invalid without a city' do
      listing = Listing.new(
        title: 'Cozy room',
        price: 600,
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:city]).to include("can't be blank")
    end

    it 'is invalid without a status' do
      listing = Listing.new(
        title: 'Cozy room',
        price: 600,
        city: 'New York',
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with an invalid status' do
      listing = Listing.new(
        title: 'Cozy room',
        price: 600,
        city: 'New York',
        status: 'invalid_status',
        owner_email: user.email,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:status]).to include("is not included in the list")
    end

    it 'is invalid without an owner email' do
      listing = Listing.new(
        title: 'Cozy room',
        price: 600,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        user: user
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:owner_email]).to include("can't be blank")
    end

    it 'is valid with all required attributes' do
      listing = Listing.new(
        title: 'Cozy room near campus',
        description: 'Small furnished room',
        price: 600,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
      expect(listing).to be_valid
    end
  end

  describe '#mark_as_verified!' do
    let(:user) { User.create!(email: 'verify@example.com', password: 'password123') }
    let(:listing) do
      Listing.create!(
        title: 'Needs verification',
        description: 'Waiting to be verified',
        price: 750,
        city: 'Chicago',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user,
        verified: false
      )
    end

    it 'updates status and verified flag' do
      listing.mark_as_verified!

      expect(listing.status).to eq(Listing::STATUS_VERIFIED)
      expect(listing.verified).to be(true)
    end
  end

  describe 'image helpers' do
    let(:user) { User.create!(email: 'images@example.com', password: 'password123') }
    let(:listing) do
      Listing.create!(
        title: 'With images',
        description: 'Listing with attachments',
        price: 1200,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
    end

    def attach_blob(record, filename: 'test.png', content_type: 'image/png', content: 'image-data')
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(content),
        filename: filename,
        content_type: content_type
      )
      record.images.attach(blob)
      record.images.last
    end

    it 'returns nil when no images are attached' do
      expect(listing.primary_image).to be_nil
      expect(listing.ordered_images).to eq([])
    end

    it 'returns the designated primary image and orders accordingly' do
      first_image = attach_blob(listing, filename: 'first.png')
      primary = attach_blob(listing, filename: 'primary.png')

      listing.set_primary_image!(primary.id)

      expect(listing.primary_image.id).to eq(primary.id)
      expect(listing.ordered_images.map(&:id)).to eq([primary.id, first_image.id])
    end

    it 'falls back to the first image when no primary is set' do
      first_image = attach_blob(listing, filename: 'first.png')
      attach_blob(listing, filename: 'second.png')

      expect(listing.primary_image.id).to eq(first_image.id)
      expect(listing.ordered_images.first.id).to eq(first_image.id)
    end

    it 'tracks whether an image is primary' do
      image = attach_blob(listing)

      listing.set_primary_image!(image.id)

      expect(listing.primary_image?(image)).to be(true)
    end

    it 'calculates remaining image slots' do
      3.times { attach_blob(listing, filename: SecureRandom.hex(4)) }

      expect(listing.remaining_image_slots).to eq(Listing::MAX_IMAGES - 3)
    end

    it 'validates against too many images' do
      (Listing::MAX_IMAGES + 1).times do |idx|
        attach_blob(listing, filename: "img-#{idx}.png")
      end

      expect(listing).not_to be_valid
      expect(listing.errors[:images]).to include("cannot exceed #{Listing::MAX_IMAGES} images")
    end

    it 'validates image content type' do
      attach_blob(listing, filename: 'bad.txt', content_type: 'text/plain')

      expect(listing).not_to be_valid
      expect(listing.errors[:images]).to include("must be JPEG, PNG, WebP, or GIF")
    end

    it 'validates image size' do
      large_content = 'a' * (Listing::MAX_IMAGE_SIZE + 1)
      attach_blob(listing, filename: 'large.png', content: large_content)

      expect(listing).not_to be_valid
      expect(listing.errors[:images]).to include("must be less than #{Listing::MAX_IMAGE_SIZE / 1.megabyte}MB each")
    end
  end
end
