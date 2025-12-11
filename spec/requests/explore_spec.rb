require 'rails_helper'

RSpec.describe "Explores", type: :request do
  describe "GET /explore" do
    let(:user) do
      User.create!(
        email: 'test@example.com',
        password: 'password123',
        display_name: 'Test User'
      )
    end

    context 'when user is authenticated' do
      before do
        post '/auth/login', params: { email: user.email, password: 'password123' }
      end

      it "returns http success" do
        get explore_path
        expect(response).to have_http_status(:success)
      end

      it "displays available listings" do
        listing = Listing.create!(
          title: 'Test Listing',
          description: 'A nice place',
          price: 1000,
          city: 'New York',
          status: Listing::STATUS_PUBLISHED,
          owner_email: 'owner@example.com',
          user: user
        )
        
        get explore_path
        expect(response.body).to include('Test Listing')
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to login page' do
        get explore_path
        expect(response).to redirect_to('/auth/login')
      end
    end
  end
end
