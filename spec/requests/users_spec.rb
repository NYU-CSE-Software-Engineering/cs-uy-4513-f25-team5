require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /new" do
    it "renders the signup page" do
      get auth_register_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("form") # crude check that form is rendered
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_params) do
        {
          user: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates a new user and redirects to dashboard (HTML)" do
        post auth_register_path, params: valid_params
        expect(response).to redirect_to(dashboard_path)
        follow_redirect!
        expect(response.body).to include("Welcome! You have successfully signed up.")
      end

      it "creates a new user and returns JSON (JSON request)" do
        post auth_register_path, params: valid_params, headers: { "ACCEPT" => "application/json" }
        expect(response.content_type).to eq("application/json; charset=utf-8")
        json = JSON.parse(response.body)
        expect(json["user"]["email"]).to eq("test@example.com")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            email: "",
            password: "short",
            password_confirmation: "nomatch"
          }
        }
      end

      it "does not create user and re-renders new (HTML)" do
        post auth_register_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("form")
      end

      it "does not create user and returns errors (JSON request)" do
        post auth_register_path, params: invalid_params, headers: { "ACCEPT" => "application/json" }
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Email can't be blank")
      end
    end
  end
end
