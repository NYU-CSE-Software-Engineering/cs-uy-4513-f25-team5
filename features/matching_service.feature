# features/matching_service.feature
Feature: Matching Service
  As a user
  I want to be matched with compatible users
  So that I can find suitable roommates or housing partners

  Background:
    Given the following users exist with preferences:
      | email              | display_name | budget | preferred_location | sleep_schedule | pets        |
      | alice@example.com  | Alice        | 1500   | Manhattan          | Early Bird     | No pets     |
      | bob@example.com    | Bob          | 1600   | Manhattan          | Early Bird     | No pets     |
      | carol@example.com  | Carol        | 2000   | Brooklyn           | Night Owl      | Has cats    |
      | david@example.com  | David        | 1550   | Manhattan          | Early Bird     | No pets     |
      | eve@example.com    | Eve          | 800    | Queens             | Night Owl      | Has dogs    |

  Scenario: Generate matches for a user with high compatibility
    Given I am user "Alice"
    When matches are generated for me
    Then I should have matches with:
      | matched_user | minimum_score |
      | Bob          | 70            |
      | David        | 70            |
    And I should have at least 2 matches total

  Scenario: Generate matches only above minimum threshold
    Given I am user "Alice"
    And the minimum compatibility score is 50.0
    When matches are generated for me
    Then all my matches should have compatibility scores above 50.0

  Scenario: Skip creating duplicate matches
    Given I am user "Alice"
    And I already have a match with "Bob"
    When matches are generated for me
    Then I should still have only one match with "Bob"

  Scenario: Generate matches for all users
    When matches are generated for all users
    Then "Alice" should have matches
    And "Bob" should have matches
    And "Carol" should have matches

  Scenario: Regenerate matches after profile update
    Given I am user "Alice"
    And I have existing matches with "Bob" and "David"
    When I update my preferences to:
      | budget | preferred_location | sleep_schedule | pets     |
      | 2100   | Brooklyn           | Night Owl      | Has cats |
    And my matches are regenerated
    Then my old matches should be deleted
    And I should have new matches based on updated preferences
    And "Carol" should be in my new matches

  Scenario: Regenerate matches deletes all old matches
    Given I am user "Alice"
    And I have 3 existing matches
    When my matches are regenerated
    Then all my previous matches should be removed
    And new matches should be created based on current preferences

  Scenario: Generate matches returns count of matches created
    Given I am user "Alice"
    When matches are generated for me
    Then the service should return the number of matches created
    And the returned count should match the actual matches in the database

  Scenario: Generate all matches returns total count
    When matches are generated for all users
    Then the service should return the total number of matches created

  Scenario: Handle user with nil values gracefully
    Given I am user "Alice"
    And user "Bob" has incomplete profile information
    When matches are generated for me
    Then the matching process should complete without errors
    And compatibility should be calculated despite missing data

  Scenario: Skip user when generating matches for themselves
    Given I am user "Alice"
    When matches are generated for me
    Then I should not be matched with myself
    And no self-match should exist in the database

  Scenario: Multiple users matching with same target
    Given users "Alice", "Bob", and "David" have similar preferences
    When matches are generated for all users
    Then "Alice" should be matched with "Bob" and "David"
    And "Bob" should be matched with "Alice" and "David"
    And "David" should be matched with "Alice" and "Bob"

  Scenario: No matches generated for nil user
    Given the user is nil
    When matches are generated for the nil user
    Then the service should handle it gracefully

  Scenario: Regenerate maintains referential integrity
    Given I am user "Alice"
    And I have matches that are referenced by other records
    When my matches are regenerated
    Then all old matches should be properly deleted
    And no orphaned records should exist