require 'rails_helper'

RSpec.describe "LikedListings", type: :request do
  let(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'password123',
      display_name: 'Test User',
      budget: 1000,
      preferred_location: 'New York'
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

  before do
    post '/auth/login', params: { email: user.email, password: 'password123' }
  end

  describe "POST /listings/:listing_id/like" do
    it "creates a liked listing" do
      expect {
        post like_listing_path(listing)
      }.to change(LikedListing, :count).by(1)
    end

    it "redirects back with success message" do
      post like_listing_path(listing)
      expect(response).to redirect_to(listing_path(listing))
      follow_redirect!
      expect(response.body).to include('saved to favorites')
    end

    it "does not create duplicate likes" do
      LikedListing.create!(user: user, listing: listing)
      expect {
        post like_listing_path(listing)
      }.not_to change(LikedListing, :count)
    end
  end

  describe "DELETE /listings/:listing_id/unlike" do
    before do
      LikedListing.create!(user: user, listing: listing)
    end

    it "removes the liked listing" do
      expect {
        delete unlike_listing_path(listing)
      }.to change(LikedListing, :count).by(-1)
    end

    it "redirects back with success message" do
      delete unlike_listing_path(listing)
      expect(response).to redirect_to(listing_path(listing))
      follow_redirect!
      expect(response.body).to include('removed from favorites')
    end
  end

  describe "GET /liked_listings" do
    before do
      LikedListing.create!(user: user, listing: listing)
    end

    it "returns http success" do
      get liked_listings_path
      expect(response).to have_http_status(:success)
    end

    it "displays liked listings" do
      get liked_listings_path
      expect(response.body).to include('Test Listing')
    end
  end

  context 'when user is not authenticated' do
    before do
      post '/auth/logout' rescue nil
    end

    it 'redirects to login page when trying to like' do
      post like_listing_path(listing)
      expect(response).to redirect_to('/auth/login')
    end

    it 'redirects to login page when trying to view liked listings' do
      get liked_listings_path
      expect(response).to redirect_to('/auth/login')
    end
  end
end
