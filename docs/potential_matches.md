# Potential Matches Feature

## User Story

**As a** Member  
**I want to** view potential roommate matches  
**So that** I can find compatible roommates to share housing costs

## Acceptance Criteria

1. **Happy Path**: When I visit the matches page, I should see a list of potential roommate matches with their basic information and compatibility scores.

2. **Edge Case**: When there are no potential matches available, I should see a message indicating "No matches found" with suggestions to update my profile preferences.

3. **Failure Case**: When I try to access the matches page without being logged in, I should be redirected to the login page.

4. **Match Details**: When I click on a potential match, I should see detailed information including their profile, lifestyle preferences, and compatibility score.

5. **Like/Save Match**: When I like a potential match, it should be saved to my favorites and I should see a confirmation message.

## MVC Components

### Model
- **Match**: Stores potential roommate matches with compatibility scores
  - `id`, `user_id`, `matched_user_id`, `compatibility_score`, `created_at`, `updated_at`
- **User**: Core user information
  - `id`, `name`, `email`, `created_at`, `updated_at`
- **Profile**: Extended user profile data
  - `id`, `user_id`, `budget`, `location`, `lifestyle_preferences`, `created_at`, `updated_at`

### View
- **matches/index.html.erb**: Dashboard page displaying list of potential matches
- **matches/show.html.erb**: Detailed view of a specific match
- **shared/_match_card.html.erb**: Partial for displaying individual match cards
- **shared/_no_matches.html.erb**: Partial for displaying when no matches are found

### Controller
- **MatchesController**: Handles match-related actions
  - `index`: Displays list of potential matches for current user
  - `show`: Displays detailed information for a specific match
  - `like`: Saves a match to user's favorites
  - `history`: Displays user's match history

## Dependencies
- User authentication system (assumes user is logged in)
- Profile management system for user preferences
- Matching algorithm service for generating potential matches
