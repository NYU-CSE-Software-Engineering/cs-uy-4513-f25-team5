require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let(:user1) { User.create!(email: 'user1@example.com', password: 'password123') }
  let(:user2) { User.create!(email: 'user2@example.com', password: 'password123') }

  describe 'associations' do
    it 'belongs to participant_one as a User' do
      conversation = Conversation.create!(
        participant_one_id: user1.id,
        participant_two_id: user2.id
      )

      expect(conversation.participant_one).to eq(user1)
    end

    it 'has many messages' do
      conversation = Conversation.create!(
        participant_one_id: user1.id,
        participant_two_id: user2.id
      )

      msg1 = Message.create!(conversation: conversation, user: user1, body: 'Hello')
      msg2 = Message.create!(conversation: conversation, user: user2, body: 'Hi!')
      msg3 = Message.create!(conversation: conversation, user: user1, body: 'How are you?')

      expect(conversation.messages).to include(msg1, msg2, msg3)
      expect(conversation.messages.count).to eq(3)
    end
  end

  describe 'validations' do
    it 'is invalid without participant_one' do
      conversation = Conversation.new(
        participant_two_id: user2.id
      )

      expect(conversation).not_to be_valid
      expect(conversation.errors[:participant_one]).to be_present
    end

    it 'is invalid without participant_two' do
      conversation = Conversation.new(
        participant_one_id: user1.id
      )

      expect(conversation).not_to be_valid
      expect(conversation.errors[:participant_two]).to be_present
    end

    it 'does not allow duplicate conversations between the same two users' do
      # pending "get back to this..."
      Conversation.create!(
        participant_one_id: user1.id,
        participant_two_id: user2.id
      )

      duplicate = Conversation.new(
        participant_one_id: user1.id,
        participant_two_id: user2.id
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:base]).to include("Conversation already exists between these users")
      # ^ Update the message above to match your actual validation error message.
    end
  end
end
