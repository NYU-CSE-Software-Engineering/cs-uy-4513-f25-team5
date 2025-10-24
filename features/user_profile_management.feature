Feature: Manage a user profile
  As a signed-in user
  I want to manage my roommate profile
  So that potential roommates understand my preferences

  Background:
    Given the test database is clean
    And I am a signed-in user
    And I have a profile with:
      | display_name       | Steven Li |
      | bio                | Easygoing roommate who enjoys cooking |
      | budget             | 1200 |
      | preferred_location | Brooklyn, NY |
      | sleep_schedule     | Early riser |
      | pets               | No pets |
      | housing_status     | Looking for roommate |
      | contact_visibility | Friends only |

  Scenario: User views their existing profile
    When I visit my profile page
    Then I should see my profile information:
      | display_name       | Steven Li |
      | bio                | Easygoing roommate who enjoys cooking |
      | budget             | 1200 |
      | preferred_location | Brooklyn, NY |
      | sleep_schedule     | Early riser |
      | pets               | No pets |
      | housing_status     | Looking for roommate |
      | contact_visibility | Friends only |

  Scenario: User updates profile with valid preferences
    When I update my profile with:
      | display_name       | Steven L. |
      | bio                | Night owl product designer looking for tidy roommate |
      | budget             | 1500 |
      | preferred_location | Manhattan, NY |
      | sleep_schedule     | Night owl |
      | pets               | Open to cats |
      | housing_status     | Matched but flexible |
      | contact_visibility | Everyone |
    Then my profile should be saved with:
      | display_name       | Steven L. |
      | bio                | Night owl product designer looking for tidy roommate |
      | budget             | 1500 |
      | preferred_location | Manhattan, NY |
      | sleep_schedule     | Night owl |
      | pets               | Open to cats |
      | housing_status     | Matched but flexible |
      | contact_visibility | Everyone |
    And I should see a profile update confirmation "Profile updated successfully"

  Scenario: User fails to update profile without a display name
    When I attempt to update my profile with:
      | display_name       |  |
      | bio                | Missing display name should trigger validation |
      | budget             | 1100 |
      | preferred_location | Queens, NY |
      | sleep_schedule     | Early riser |
      | pets               | No pets |
      | housing_status     | Looking for roommate |
      | contact_visibility | Friends only |
    Then the profile should not be saved
    And I should see a profile validation error "Display name can't be blank"

  Scenario: User removes their profile picture
    Given I have uploaded a profile picture
    When I remove my profile picture
    Then I should see a profile picture placeholder
    And my profile should not have a profile picture

  Scenario: User fails to update profile with a negative budget
    When I attempt to update my profile with:
      | display_name       | Steven Li |
      | bio                | Budget must not be negative |
      | budget             | -500 |
      | preferred_location | Brooklyn, NY |
      | sleep_schedule     | Early riser |
      | pets               | No pets |
      | housing_status     | Looking for roommate |
      | contact_visibility | Friends only |
    Then the profile should not be saved
    And I should see a profile validation error "Budget must be greater than or equal to 0"
