require 'rails_helper'

RSpec.describe "VerificationRequests", type: :request do
  describe "GET /verification_requests" do
    it "renders the index template" do
      get "/verification_requests"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Verification Requests")
    end
  end
end
