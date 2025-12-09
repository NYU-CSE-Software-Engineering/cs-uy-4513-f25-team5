require 'rails_helper'

# Request spec mirroring docs/features/search_listings.md behavior expectations.
RSpec.describe 'Search Listings', type: :request do
  let!(:user) { User.create!(email: 'owner@example.com', password: 'password123') }
  let!(:matching_listing) do
    Listing.create!(
      title: 'NYC Loft',
      description: 'Close to campus with skyline views',
      price: 1500,
      city: 'New York',
      user: user,
      status: Listing::STATUS_PENDING,
      owner_email: user.email
    )
  end
  let!(:non_matching_listing) do
    Listing.create!(
      title: 'SF Flat',
      description: 'Bay views near Golden Gate',
      price: 2800,
      city: 'San Francisco',
      user: user,
      status: Listing::STATUS_PENDING,
      owner_email: user.email
    )
  end

  describe 'GET /search/listings' do
    it 'filters listings by city, price range, and keywords' do
      get '/search/listings', params: {
        city: 'New York',
        min_price: 1000,
        max_price: 2000,
        keywords: 'Loft'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching_listing.title)
      expect(response.body).not_to include(non_matching_listing.title)
    end

    it 'renders a no results message when nothing matches' do
      get '/search/listings', params: { city: 'Boston', keywords: 'penthouse' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No results found')
    end
  end

  describe 'search history saving' do
    context 'when user is logged in' do
      let(:searcher) { User.create!(email: 'searcher@example.com', password: 'password123') }

      before do
        post '/auth/login', params: { email: searcher.email, password: 'password123' }
      end

      it 'saves search history when searching with parameters' do
        expect {
          get '/listings/search', params: { city: 'New York', min_price: 1000 }
        }.to change(SearchHistory, :count).by(1)
      end
    end
  end
end
