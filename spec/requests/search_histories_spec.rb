require 'rails_helper'

RSpec.describe 'Search Histories', type: :request do
  describe 'GET /search/history' do
    context 'when user is not logged in' do
      it 'redirects to login page' do
        get '/search/history'
        expect(response).to redirect_to(auth_login_path)
      end
    end
  end
end
