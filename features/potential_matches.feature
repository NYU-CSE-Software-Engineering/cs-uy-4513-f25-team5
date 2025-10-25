Feature: Viewing Potential Matches
  As a Member
  I want to view potential roommate matches
  So that I can find compatible roommates to share housing costs

  Background:
    Given I am logged in as a user
    And I have a profile with preferences

  Scenario: View potential matches successfully
    Given there are potential matches available
    When I visit the matches page
    Then I should see a list of potential matches
    And each match should display basic information
    And each match should show a compatibility score

  Scenario: View match details
    Given there are potential matches available
    When I visit the matches page
    And I click on a potential match
    Then I should see detailed match information
    And I should see their profile information
    And I should see the compatibility score
    And I should see lifestyle preferences

  Scenario: No matches available
    Given there are no potential matches available
    When I visit the matches page
    Then I should see "No matches found" message
    And I should see suggestions to update my profile

  Scenario: Like a potential match
    Given there are potential matches available
    When I visit the matches page
    And I click the "Like" button on a match
    Then I should see a confirmation message
    And the match should be saved to my favorites

  Scenario: Access matches without login
    Given I am not logged in
    When I try to visit the matches page
    Then I should be redirected to the login page
