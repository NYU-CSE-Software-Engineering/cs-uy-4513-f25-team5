require 'rails_helper'

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

  describe '#update' do
    let(:user) { User.create!(email: 'owner@example.com', password: 'password123') }
    let(:listing) do
      Listing.create!(
        title: 'Original Title',
        description: 'Original description',
        price: 800,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
    end

    it 'updates valid attributes successfully' do
      expect(listing.update(description: 'Updated description', price: 950)).to be true
      listing.reload
      expect(listing.description).to eq('Updated description')
      expect(listing.price).to eq(950)
    end

    it 'fails to update with blank title' do
      expect(listing.update(title: '')).to be false
      expect(listing.errors[:title]).to include("can't be blank")
    end

    it 'fails to update with negative price' do
      expect(listing.update(price: -1000)).to be false
      expect(listing.errors[:price]).to include('must be greater than 0')
    end

    it 'preserves original values when update fails' do
      original_title = listing.title
      original_price = listing.price
      
      listing.update(title: '', price: -100)
      listing.reload
      
      expect(listing.title).to eq(original_title)
      expect(listing.price).to eq(original_price)
    end
  end

  describe '#destroy' do
    let(:user) { User.create!(email: 'owner@example.com', password: 'password123') }
    let(:listing) do
      Listing.create!(
        title: 'To Be Deleted',
        price: 500,
        city: 'Boston',
        status: Listing::STATUS_PENDING,
        owner_email: user.email,
        user: user
      )
    end

    it 'successfully deletes a listing' do
      listing_id = listing.id
      expect { listing.destroy }.to change(Listing, :count).by(-1)
      expect(Listing.find_by(id: listing_id)).to be_nil
    end
  end
end
