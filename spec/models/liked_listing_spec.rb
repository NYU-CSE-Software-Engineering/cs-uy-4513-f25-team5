require 'rails_helper'

RSpec.describe LikedListing, type: :model do
  let(:user) do
    User.create!(
      email: 'user@example.com',
      password: 'password123',
      display_name: 'Test User'
    )
  end

  let(:listing) do
    Listing.create!(
      title: 'Test Listing',
      description: 'A nice place',
      price: 1000,
      city: 'New York',
      status: Listing::STATUS_PUBLISHED,
      owner_email: 'owner@example.com'
    )
  end

  describe 'associations' do
    it 'belongs to user' do
      liked_listing = LikedListing.create!(user: user, listing: listing)
      expect(liked_listing.user).to eq(user)
    end

    it 'belongs to listing' do
      liked_listing = LikedListing.create!(user: user, listing: listing)
      expect(liked_listing.listing).to eq(listing)
    end
  end

  describe 'validations' do
    it 'is invalid without a user' do
      liked_listing = LikedListing.new(listing: listing)
      expect(liked_listing).not_to be_valid
      expect(liked_listing.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid without a listing' do
      liked_listing = LikedListing.new(user: user)
      expect(liked_listing).not_to be_valid
      expect(liked_listing.errors[:listing_id]).to include("can't be blank")
    end

    it 'prevents duplicate likes' do
      LikedListing.create!(user: user, listing: listing)
      duplicate = LikedListing.new(user: user, listing: listing)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already liked this listing")
    end

    it 'allows different users to like the same listing' do
      user2 = User.create!(
        email: 'user2@example.com',
        password: 'password123',
        display_name: 'User Two'
      )
      
      LikedListing.create!(user: user, listing: listing)
      liked_listing2 = LikedListing.new(user: user2, listing: listing)
      expect(liked_listing2).to be_valid
    end

    it 'allows a user to like different listings' do
      listing2 = Listing.create!(
        title: 'Another Listing',
        description: 'Another nice place',
        price: 1200,
        city: 'Boston',
        status: Listing::STATUS_PUBLISHED,
        owner_email: 'owner2@example.com'
      )
      
      LikedListing.create!(user: user, listing: listing)
      liked_listing2 = LikedListing.new(user: user, listing: listing2)
      expect(liked_listing2).to be_valid
    end
  end
end
