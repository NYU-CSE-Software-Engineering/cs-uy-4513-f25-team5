require 'rails_helper'

RSpec.describe 'Access control', type: :request do
  it 'redirects unauthenticated users from a protected page' do
    # Using verification queue as a protected example in our app
    get '/verification_requests'
    expect(response).to have_http_status(:redirect)
    # Once login page exists, this should point there
    expect(response.headers['Location']).to be_present
    expect(response.headers['Location']).to match(/login|sessions|auth/i)
  end
end

