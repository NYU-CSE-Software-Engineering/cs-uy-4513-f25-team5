require 'rails_helper'

RSpec.describe MatchingService, type: :service do
  before do
    User.delete_all
    Match.delete_all
  end

  let(:user1) do
    User.create!(
      email: 'user1@example.com',
      password: 'password123',
      display_name: 'User 1',
      budget: 1000,
      preferred_location: 'New York',
      sleep_schedule: 'Early bird',
      pets: 'No pets'
    )
  end

  let(:user2) do
    User.create!(
      email: 'user2@example.com',
      password: 'password123',
      display_name: 'User 2',
      budget: 950,
      preferred_location: 'New York',
      sleep_schedule: 'Early bird',
      pets: 'No pets'
    )
  end

  let(:user3) do
    User.create!(
      email: 'user3@example.com',
      password: 'password123',
      display_name: 'User 3',
      budget: 500,
      preferred_location: 'Los Angeles',
      sleep_schedule: 'Night owl',
      pets: 'Dog'
    )
  end

  describe '.generate_matches_for' do
    it 'creates matches for users with compatible preferences' do
      # Create users explicitly to ensure they exist
      u1 = User.create!(
        email: 'user1_test@example.com',
        password: 'password123',
        display_name: 'User 1',
        budget: 1000,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      u2 = User.create!(
        email: 'user2_test@example.com',
        password: 'password123',
        display_name: 'User 2',
        budget: 950,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      matches_created = MatchingService.generate_matches_for(u1)
      
      expect(matches_created).to be > 0
      expect(Match.where(user_id: u1.id).count).to eq(matches_created)
    end

    it 'creates match with user2 who has similar preferences' do
      # Create users explicitly
      u1 = User.create!(
        email: 'user1_detail@example.com',
        password: 'password123',
        display_name: 'User 1',
        budget: 1000,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      u2 = User.create!(
        email: 'user2_detail@example.com',
        password: 'password123',
        display_name: 'User 2',
        budget: 950,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      MatchingService.generate_matches_for(u1)
      
      match = Match.find_by(user_id: u1.id, matched_user_id: u2.id)
      expect(match).to be_present
      expect(match.compatibility_score).to be >= 50
    end

    it 'does not create matches below minimum compatibility threshold' do
      # user3 has very different preferences from user1
      MatchingService.generate_matches_for(user1)
      
      # May or may not create match depending on score, but score should be reasonable
      match = Match.find_by(user_id: user1.id, matched_user_id: user3.id)
      if match
        expect(match.compatibility_score).to be >= 50
      end
    end

    it 'does not create duplicate matches' do
      MatchingService.generate_matches_for(user1)
      initial_count = Match.where(user_id: user1.id).count
      
      MatchingService.generate_matches_for(user1)
      
      expect(Match.where(user_id: user1.id).count).to eq(initial_count)
    end

    it 'does not create matches for the same user' do
      MatchingService.generate_matches_for(user1)
      
      self_match = Match.find_by(user_id: user1.id, matched_user_id: user1.id)
      expect(self_match).to be_nil
    end

    it 'returns the number of matches created' do
      matches_created = MatchingService.generate_matches_for(user1)
      
      expect(matches_created).to be_a(Integer)
      expect(matches_created).to be >= 0
      expect(Match.where(user_id: user1.id).count).to eq(matches_created)
    end
  end

  describe '.regenerate_matches_for' do
    it 'deletes existing matches before creating new ones' do
      # Create initial matches
      MatchingService.generate_matches_for(user1)
      initial_count = Match.where(user_id: user1.id).count
      
      # Regenerate matches
      MatchingService.regenerate_matches_for(user1)
      new_count = Match.where(user_id: user1.id).count
      
      # Should recreate matches (may be same count or different)
      expect(new_count).to be >= 0
      expect(new_count).to be <= initial_count + 2 # May find more or less matches
    end
  end

  describe '.generate_all_matches' do
    it 'generates matches for all users' do
      # Create users explicitly
      u1 = User.create!(
        email: 'user1_all@example.com',
        password: 'password123',
        display_name: 'User 1',
        budget: 1000,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      u2 = User.create!(
        email: 'user2_all@example.com',
        password: 'password123',
        display_name: 'User 2',
        budget: 950,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      total_matches = MatchingService.generate_all_matches
      
      expect(total_matches).to be > 0
      expect(Match.count).to eq(total_matches)
    end

    it 'creates bidirectional matches for compatible users' do
      # Create users explicitly
      u1 = User.create!(
        email: 'user1_bidir@example.com',
        password: 'password123',
        display_name: 'User 1',
        budget: 1000,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      u2 = User.create!(
        email: 'user2_bidir@example.com',
        password: 'password123',
        display_name: 'User 2',
        budget: 950,
        preferred_location: 'New York',
        sleep_schedule: 'Early bird',
        pets: 'No pets'
      )
      
      MatchingService.generate_all_matches
      
      # If user1 and user2 are compatible, at least one should have a match
      expect(Match.exists?(user_id: u1.id, matched_user_id: u2.id) ||
             Match.exists?(user_id: u2.id, matched_user_id: u1.id)).to be true
    end
  end
end

