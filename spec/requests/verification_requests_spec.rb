require 'rails_helper'

RSpec.describe "VerificationRequests", type: :request do
  describe "GET /verification_requests" do
    it "renders the index template" do
      user = User.create!(email: "test@example.com", password: "password123")
      listing = Listing.create!(
        title: "Test Listing",
        price: 1000,
        city: "Test City",
        status: "pending",
        owner_email: "test@example.com",
        verification_requested: true,
        user: user
      )

      # Log in first
      post '/auth/login', params: { email: user.email, password: 'password123' }
      
      get "/verification_requests"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Verification Requests")
    end
  end

  describe "PATCH /listings/:id/verify" do
    it "marks a listing as verified and redirects" do
      user = User.create!(email: "test2@example.com", password: "password123")
      listing = Listing.create!(
        title: "Test Listing 2",
        price: 1500,
        city: "Test City 2",
        status: "pending",
        owner_email: "test2@example.com",
        verification_requested: true,
        user: user
      )

      # Log in first
      post '/auth/login', params: { email: user.email, password: 'password123' }

      patch "/listings/#{listing.id}/verify"

      expect(response).to redirect_to(verification_requests_path)
      follow_redirect!

      listing.reload
      expect(listing.status).to eq(Listing::STATUS_VERIFIED)
    end
  end
end
