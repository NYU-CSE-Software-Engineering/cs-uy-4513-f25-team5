require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user1) { User.create!(email: 'user1@example.com', password: 'password123') }
  let(:user2) { User.create!(email: 'user2@example.com', password: 'password123') }
  let(:conversation) do
    Conversation.create!(
      participant_one_id: user1.id,
      participant_two_id: user2.id
    )
  end

  describe 'associations' do
    it 'belongs to a conversation' do
      message = Message.create!(conversation: conversation, user: user1, body: 'Hello')

      expect(message.conversation).to eq(conversation)
    end

    it 'belongs to a user' do
      message = Message.create!(conversation: conversation, user: user1, body: 'Hello')

      expect(message.user).to eq(user1)
    end
  end

  describe 'validations' do
    it 'is invalid without a body' do
      message = Message.new(conversation: conversation, user: user1, body: nil)

      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without a conversation' do
      message = Message.new(conversation: nil, user: user1, body: "Hello")

      expect(message).not_to be_valid
      expect(message.errors[:conversation]).to include("must exist")
    end

    it 'is invalid without a user' do
      message = Message.new(conversation: conversation, user: nil, body: "Hello")

      expect(message).not_to be_valid
      expect(message.errors[:user]).to include("must exist")
    end
  end
end
