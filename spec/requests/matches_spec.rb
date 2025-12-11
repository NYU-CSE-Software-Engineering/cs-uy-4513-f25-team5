require 'rails_helper'

RSpec.describe "Matches", type: :request do
  let(:user) do
    User.create!(
      email: 'user@example.com',
      password: 'password123',
      display_name: 'Test User',
      budget: 1000,
      preferred_location: 'New York',
      sleep_schedule: 'Early bird'
    )
  end

  let(:matched_user1) do
    User.create!(
      email: 'match1@example.com',
      password: 'password123',
      display_name: 'Match User 1',
      budget: 950,
      preferred_location: 'New York',
      sleep_schedule: 'Early bird'
    )
  end

  let(:matched_user2) do
    User.create!(
      email: 'match2@example.com',
      password: 'password123',
      display_name: 'Match User 2',
      budget: 1100,
      preferred_location: 'New York',
      sleep_schedule: 'Regular schedule'
    )
  end

  before do
    # Log in the user using real session authentication
    post '/auth/login', params: { email: user.email, password: 'password123' }
  end

  describe 'GET /matches' do
    context 'when user is authenticated' do
      it 'returns http success' do
        get matches_path
        expect(response).to have_http_status(:success)
      end

      it 'displays potential matches for the current user' do
        match1 = Match.create!(user: user, matched_user: matched_user1, compatibility_score: 85)
        match2 = Match.create!(user: user, matched_user: matched_user2, compatibility_score: 78)

        get matches_path
        expect(response.body).to include(matched_user1.display_name)
        expect(response.body).to include(matched_user2.display_name)
        # Compatibility scores are hidden from UI per reviewer feedback
      end

      it 'displays message when no matches are available' do
        get matches_path
        expect(response.body).to include('No matches found')
      end

      it 'does not display matches for other users' do
        other_user = User.create!(
          email: 'other@example.com',
          password: 'password123',
          display_name: 'Other User'
        )
        Match.create!(user: other_user, matched_user: matched_user1, compatibility_score: 90)

        get matches_path
        expect(response.body).not_to include(matched_user1.display_name)
      end
    end

    context 'when user is not authenticated' do
      before do
        # Clear session to simulate not being logged in
        post '/auth/logout' rescue nil
        session.clear
      end

      it 'redirects to login page' do
        get matches_path
        expect(response).to redirect_to('/auth/login')
      end
    end
  end

  describe 'GET /matches/:id' do
    let(:match) do
      Match.create!(user: user, matched_user: matched_user1, compatibility_score: 85)
    end

    context 'when user is authenticated' do
      it 'returns http success' do
        get match_path(match)
        expect(response).to have_http_status(:success)
      end

      it 'displays detailed match information' do
        get match_path(match)
        expect(response.body).to include(matched_user1.display_name)
        # Compatibility scores are hidden from UI per reviewer feedback
      end

      it 'displays user profile information' do
        get match_path(match)
        expect(response.body).to include(matched_user1.display_name)
        expect(response.body).to include(matched_user1.preferred_location) if matched_user1.preferred_location.present?
      end

      it 'displays lifestyle preferences' do
        get match_path(match)
        expect(response.body).to include(matched_user1.sleep_schedule) if matched_user1.sleep_schedule.present?
      end
    end

    context 'when user is not authenticated' do
      before do
        # Clear session to simulate not being logged in
        post '/auth/logout' rescue nil
        session.clear
      end

      it 'redirects to login page' do
        get match_path(match)
        expect(response).to redirect_to('/auth/login')
      end
    end
  end

  describe 'POST /matches/generate' do
    context 'when user is authenticated' do
      it 'generates matches for the current user' do
        # Create another user for matching
        other_user = User.create!(
          email: 'other@example.com',
          password: 'password123',
          display_name: 'Other User',
          budget: 1100,
          preferred_location: 'New York',
          sleep_schedule: 'Early bird'
        )
        
        post generate_matches_path
        expect(response).to redirect_to(matches_path)
      end

      it 'displays success message when matches are found' do
        other_user = User.create!(
          email: 'other@example.com',
          password: 'password123',
          display_name: 'Other User',
          budget: 1100,
          preferred_location: 'New York',
          sleep_schedule: 'Early bird'
        )
        
        post generate_matches_path
        follow_redirect!
        expect(response.body).to include('new potential match')
      end

      it 'displays message when no matches are found' do
        # No other users exist
        post generate_matches_path
        follow_redirect!
        expect(response.body).to include('No new matches found')
      end
    end

    context 'when user is not authenticated' do
      before do
        post '/auth/logout' rescue nil
        session.clear
      end

      it 'redirects to login page' do
        post generate_matches_path
        expect(response).to redirect_to('/auth/login')
      end
    end
  end

  # Like feature removed per reviewer feedback to simplify UI and reduce schema complexity
  # Tests removed: POST /matches/:id/like
end

