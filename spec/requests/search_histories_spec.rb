require 'rails_helper'

RSpec.describe 'Search Histories', type: :request do
  describe 'GET /search/history' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get '/search/history'
        expect(response).to redirect_to(auth_login_path)
      end
    end

    context 'when user is logged in' do
      let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

      before do
        post '/auth/login', params: { email: user.email, password: 'password123' }
      end

      it 'returns a successful response' do
        get '/search/history'
        expect(response).to have_http_status(:success)
      end

      it 'displays user search histories' do
        user.search_histories.create!(city: 'New York')
        get '/search/history'
        expect(response.body).to include('New York')
      end

      it 'displays search histories in reverse chronological order' do
        user.search_histories.create!(city: 'Boston', created_at: 1.day.ago)
        user.search_histories.create!(city: 'Chicago', created_at: Time.current)
        get '/search/history'
        expect(response.body.index('Chicago')).to be < response.body.index('Boston')
      end

      it 'limits to 20 most recent searches' do
        25.times { |i| user.search_histories.create!(city: "City#{i}") }
        get '/search/history'
        expect(response.body).to include('City24')  # newest
        expect(response.body).not_to include('City0')  # oldest (beyond limit)
      end

      it 'only shows current user search histories' do
        other_user = User.create!(email: 'other@example.com', password: 'password123')
        other_user.search_histories.create!(city: 'Secret City')
        user.search_histories.create!(city: 'My City')

        get '/search/history'
        expect(response.body).to include('My City')
        expect(response.body).not_to include('Secret City')
      end
    end
  end
end
