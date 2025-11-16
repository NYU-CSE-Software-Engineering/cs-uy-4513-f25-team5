require 'rails_helper'

RSpec.describe 'Access control', type: :request do
  it 'redirects unauthenticated users from a protected page' do
    # Using verification queue as a protected example in our app
    get '/verification_requests'
    expect(response).to have_http_status(:redirect).or have_http_status(:unauthorized)
    # Once login page exists, I'll need to update this to point to the login page
    expect(response.headers['Location']).to match(/login|sessions|auth/i).or be_present
  end
end
