require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /auth/register' do
    it 'creates a user and logs them in on valid params' do
      post '/auth/register', params: { user: { email: 'new@example.com', password: 'password123' } }
      expect(response).to have_http_status(:redirect).or have_http_status(:created)
      # Expect session to be established once implemented
      expect(session[:user_id]).to be_present
    end
  end
  describe 'POST /auth/login' do
    let!(:user) { User.create!(email: 'login@example.com', password: 'password123') }

    it 'logs in with valid credentials' do
      post '/auth/login', params: { email: user.email, password: 'password123' }
      expect(response).to have_http_status(:redirect).or have_http_status(:ok)
      expect(session[:user_id]).to eq(user.id)
    end

    it 'rejects invalid credentials' do
      post '/auth/login', params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized).or have_http_status(:unprocessable_entity)
      expect(session[:user_id]).to be_nil
    end
  end

  describe 'POST /auth/logout' do
    it 'clears the session' do
      user = User.create!(email: 'out@example.com', password: 'password123')
      # simulate logged in
      post '/auth/login', params: { email: user.email, password: 'password123' }
      expect(session[:user_id]).to eq(user.id)

      post '/auth/logout'
      expect(response).to have_http_status(:redirect).or have_http_status(:no_content)
      expect(session[:user_id]).to be_nil
    end
  end
end

