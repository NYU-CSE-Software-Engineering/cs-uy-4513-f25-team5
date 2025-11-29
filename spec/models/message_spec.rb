require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it 'belongs to a conversation' do
      user1 = User.create!(email: 'user1@example.com', password: 'password123')
      user2 = User.create!(email: 'user2@example.com', password: 'password123')
      conversation = Conversation.create!(participant_one_id: user1.id, participant_two_id: user2.id)
      message = Message.create!(conversation: conversation, user: user1, body: 'Hello')

      expect(message.conversation).to eq(conversation)
    end
  end

  describe 'validations' do
    it 'is invalid without a body' do
      user = User.create!(email: 'user@example.com', password: 'password123')
      conversation = Conversation.create!(
        participant_one_id: user.id,
        participant_two_id: User.create!(email: 'other@example.com', password: 'password123').id
      )
      message = Message.new(conversation: conversation, user: user, body: nil)

      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("can't be blank")
    end
  end
end

