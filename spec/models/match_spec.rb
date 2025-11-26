require 'rails_helper'

RSpec.describe Match, type: :model do
  describe 'validations' do
    it 'is invalid without a user_id' do
      match = Match.new(matched_user_id: 1, compatibility_score: 85)
      expect(match).not_to be_valid
      expect(match.errors[:user_id]).to include("can't be blank")
    end

    it 'is invalid without a matched_user_id' do
      match = Match.new(user_id: 1, compatibility_score: 85)
      expect(match).not_to be_valid
      expect(match.errors[:matched_user_id]).to include("can't be blank")
    end

    it 'is invalid without a compatibility_score' do
      match = Match.new(user_id: 1, matched_user_id: 2)
      expect(match).not_to be_valid
      expect(match.errors[:compatibility_score]).to include("can't be blank")
    end

    it 'is invalid with a compatibility_score less than 0' do
      match = Match.new(user_id: 1, matched_user_id: 2, compatibility_score: -1)
      expect(match).not_to be_valid
      expect(match.errors[:compatibility_score]).to include("must be greater than or equal to 0")
    end

    it 'is invalid with a compatibility_score greater than 100' do
      match = Match.new(user_id: 1, matched_user_id: 2, compatibility_score: 101)
      expect(match).not_to be_valid
      expect(match.errors[:compatibility_score]).to include("must be less than or equal to 100")
    end

    it 'prevents matching a user with themselves' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      match = Match.new(user_id: user.id, matched_user_id: user.id, compatibility_score: 85)
      expect(match).not_to be_valid
      expect(match.errors[:matched_user_id]).to include("can't be the same as user")
    end
  end

  describe 'associations' do
    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'belongs to matched_user' do
      association = described_class.reflect_on_association(:matched_user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'scopes' do
    before do
      User.delete_all
      Match.delete_all
      
      @user1 = User.create!(email: 'user1@example.com', password: 'password123')
      @user2 = User.create!(email: 'user2@example.com', password: 'password123')
      @user3 = User.create!(email: 'user3@example.com', password: 'password123')
      
      @match1 = Match.create!(user: @user1, matched_user: @user2, compatibility_score: 85)
      @match2 = Match.create!(user: @user1, matched_user: @user3, compatibility_score: 78)
      Match.create!(user: @user2, matched_user: @user3, compatibility_score: 90)
    end

    it 'returns matches for a specific user' do
      matches = Match.potential_for(@user1)
      expect(matches).to include(@match1, @match2)
      expect(matches.count).to eq(2)
    end

    it 'does not return matches for other users' do
      matches = Match.potential_for(@user1)
      expect(matches).not_to include(Match.where(user: @user2).first)
    end
  end

  describe '#calculate_compatibility_score' do
    before do
      User.delete_all
      Match.delete_all
    end

    it 'calculates compatibility based on budget similarity' do
      user1 = User.create!(
        email: 'user1@example.com',
        password: 'password123',
        budget: 1000,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird'
      )
      
      user2 = User.create!(
        email: 'user2@example.com',
        password: 'password123',
        budget: 950,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird'
      )
      
      score = Match.calculate_compatibility_score(user1, user2)
      expect(score).to be_between(0, 100)
      expect(score).to be > 70 # Should be high due to similar preferences
    end

    it 'returns lower score for users with different preferences' do
      user1 = User.create!(
        email: 'user1@example.com',
        password: 'password123',
        budget: 500,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird'
      )
      
      user2 = User.create!(
        email: 'user2@example.com',
        password: 'password123',
        budget: 2000,
        preferred_location: 'Los Angeles',
        sleep_schedule: 'Night owl'
      )
      
      score = Match.calculate_compatibility_score(user1, user2)
      expect(score).to be_between(0, 100)
      expect(score).to be <= 50 # Should be lower due to different preferences
    end
  end

  describe 'callbacks' do
    it 'calculates compatibility score before validation' do
      user1 = User.create!(email: 'user1@example.com', password: 'password123', budget: 1000, preferred_location: 'NYC')
      user2 = User.create!(email: 'user2@example.com', password: 'password123', budget: 1000, preferred_location: 'NYC')
      
      match = Match.new(user: user1, matched_user: user2)
      match.valid?
      
      expect(match.compatibility_score).to be_present
      expect(match.compatibility_score).to be_between(0, 100)
    end
  end
end

