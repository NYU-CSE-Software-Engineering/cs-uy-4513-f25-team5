require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'associations' do
    it 'belongs to participant_one as a User' do
      user1 = User.create!(email: 'user1@example.com', password: 'password123')
      user2 = User.create!(email: 'user2@example.com', password: 'password123')
      conversation = Conversation.create!(participant_one_id: user1.id, participant_two_id: user2.id)

      expect(conversation.participant_one).to eq(user1)
    end

    it 'has many messages' do
      user1 = User.create!(email: 'user1@example.com', password: 'password123')
      user2 = User.create!(email: 'user2@example.com', password: 'password123')
      conversation = Conversation.create!(participant_one_id: user1.id, participant_two_id: user2.id)
      message = Message.create!(conversation: conversation, user: user1, body: 'Hello')

      expect(conversation.messages).to include(message)
    end
  end
end
