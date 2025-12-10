Feature: Search History
  As a logged-in user
  I want to see my recent searches
  So that I can quickly repeat previous searches

  Background:
    Given the test database is clean
    And I am a signed-in user

  Scenario: User views empty search history
    When I am on the search history page
    Then I should see "No search history yet"

  Scenario: User views search history after searching
    When I am on the search listings page
    And I fill in "City" with "New York"
    And I press "Search"
    And I am on the search history page
    Then I should see "New York"

  Scenario: User replays a previous search
    When I am on the search listings page
    And I fill in "City" with "Boston"
    And I press "Search"
    And I am on the search history page
    And I click on "Search Again"
    Then I should be on the search listings page
