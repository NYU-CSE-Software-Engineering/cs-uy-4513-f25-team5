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
    end
  end
end
