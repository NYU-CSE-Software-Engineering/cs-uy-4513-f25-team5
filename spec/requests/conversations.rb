require 'rails_helper'

RSpec.describe ConversationsController, type: :request do
  let!(:user1) { User.create!(email: "u1@example.com", password: "password123", display_name: "User1") }
  let!(:user2) { User.create!(email: "u2@example.com", password: "password123", display_name: "User2") }
  let!(:conversation) do
    Conversation.create!(participant_one_id: user1.id, participant_two_id: user2.id)
  end

  before do
    # simulate login
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user1)
  end

  describe "GET /conversations" do
    it "lists conversations for current user" do
      get conversations_path
      expect(response).to have_http_status(:ok)
      expect(assigns(:conversations)).to include(conversation)
    end
  end

  require "rails_helper"

  describe "GET /conversations/:id" do
    it "blocks unauthorized user" do
      owner = User.create!(email: "a@example.com", password: "password123")
      other = User.create!(email: "b@example.com", password: "password123")

      conversation = Conversation.create!(
        participant_one_id: owner.id,
        participant_two_id: other.id
      )

      unauthorized_user = User.create!(email: "unauth@example.com", password: "password123")

      # Log in unauthorized user
      post auth_login_path, params: { email: unauthorized_user.email, password: "password123" }

      get conversation_path(conversation)

      expect(response).to redirect_to(conversations_path)
      follow_redirect!

      expect(response.body).to include("You do not have access to this conversation.")

    end
  end


  describe "GET /conversations/:id/poll" do
    it "returns new messages for authorized user" do
      msg = Message.create!(body: "hello", user: user1, conversation: conversation)

      get poll_conversation_path(conversation), params: { since: 10.minutes.ago.iso8601 }
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["messages"].first["body"]).to eq("hello")
      expect(json["messages"].first["user_name"]).to eq(user1.display_name)
    end

    it "blocks unauthorized user" do
      unauthorized_user = User.create!(email: "unauth@example.com", password: "password123")
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(unauthorized_user)

      get "#{poll_conversation_path(conversation)}.json"

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Unauthorized")
    end


    it "defaults to 1 hour ago when no since param" do
      get poll_conversation_path(conversation)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /conversations" do
    it "creates or finds a conversation" do
      post conversations_path, params: { user_id: user2.id }
      expect(response).to redirect_to(conversation_path(Conversation.last))
      expect(flash[:notice]).to eq("Conversation started.")
    end

    it "fails when user does not exist" do
      post conversations_path, params: { user_id: 999999 }
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("User not found.")
    end

    it "fails when trying to message yourself" do
      post conversations_path, params: { user_id: user1.id }
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("You cannot start a conversation with yourself.")
    end

    it "redirects with error when creation fails" do
      allow_any_instance_of(Conversation).to receive(:persisted?).and_return(false)

      post conversations_path, params: { user_id: user2.id }
      expect(response).to redirect_to(dashboard_path)
      expect(flash[:alert]).to eq("Unable to create conversation.")
    end
  end

  describe "GET /conversations when not logged in" do
    it "redirects to login" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)

      get conversations_path
      expect(response).to redirect_to(auth_login_path)
      expect(flash[:alert]).to eq("You must be logged in to access conversations.")
    end
  end
end
