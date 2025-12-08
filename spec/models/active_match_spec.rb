require 'rails_helper'

RSpec.describe ActiveMatch, type: :model do
  let(:user1) { User.create!(email: 'user1@example.com', password: 'password123') }
  let(:user2) { User.create!(email: 'user2@example.com', password: 'password123') }

  describe 'associations' do
    it 'belongs to user_one as a User' do
      match = ActiveMatch.create!(user_one_id: user1.id, user_two_id: user2.id, status: 'active')
      expect(match.user_one).to eq(user1)
    end

    it 'belongs to user_two as a User' do
      match = ActiveMatch.create!(user_one_id: user1.id, user_two_id: user2.id, status: 'active')
      expect(match.user_two).to eq(user2)
    end
  end

  describe 'validations' do
    it 'is invalid without a status' do
      match = ActiveMatch.new(user_one_id: user1.id, user_two_id: user2.id, status: nil)

      expect(match).not_to be_valid
      expect(match.errors[:status]).to include("can't be blank")
    end

    it 'is invalid without user_one' do
      match = ActiveMatch.new(user_one_id: nil, user_two_id: user2.id, status: 'active')

      expect(match).not_to be_valid
      expect(match.errors[:user_one]).to include("must exist")
    end

    it 'is invalid without user_two' do
      match = ActiveMatch.new(user_one_id: user1.id, user_two_id: nil, status: 'active')

      expect(match).not_to be_valid
      expect(match.errors[:user_two]).to include("must exist")
    end
  end
end
