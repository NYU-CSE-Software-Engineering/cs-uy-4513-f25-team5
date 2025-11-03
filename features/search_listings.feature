Feature: Search for housing listings
  As a room seeker
  I want to search for housing listings by various criteria
  So that I can find my ideal residence efficiently

  Background:
    Given the test database is clean
    And I am a signed-in user

  Scenario: User searches for listings by city
    Given there are listings with the following details:
      | title                  | city      | price | description              |
      | Cozy room near campus | New York  | 600   | Small furnished room     |
      | Affordable studio     | Boston    | 800   | Studio apartment         |
      | Budget room           | New York  | 500   | Shared room              |
      | Spacious apartment    | Chicago   | 1000  | 2-bedroom apartment      |
    When I am on the search listings page
    And I fill in "City" with "New York"
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Budget room"
    And I should not see "Affordable studio"
    And I should not see "Spacious apartment"

  Scenario: User searches for listings by price range
    Given there are listings with the following details:
      | title                  | city      | price | description              |
      | Cozy room near campus | New York  | 600   | Small furnished room     |
      | Affordable studio     | Boston    | 800   | Studio apartment         |
      | Budget room           | New York  | 500   | Shared room              |
      | Spacious apartment    | Chicago   | 1000  | 2-bedroom apartment      |
    When I am on the search listings page
    And I fill in "Min Price" with "600"
    And I fill in "Max Price" with "900"
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Affordable studio"
    And I should not see "Budget room"
    And I should not see "Spacious apartment"

  Scenario: User searches for listings by keywords
    Given there are listings with the following details:
      | title                  | city      | price | description                    |
      | Cozy room near campus | New York  | 600   | Small furnished room           |
      | Affordable studio     | Boston    | 800   | Furnished studio apartment     |
      | Budget room           | New York  | 500   | Shared room                    |
      | Luxury apartment      | Chicago   | 1500  | Furnished luxury apartment     |
    When I am on the search listings page
    And I fill in "Keywords" with "furnished"
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Affordable studio"
    And I should see "Luxury apartment"
    And I should not see "Budget room"

  Scenario: User searches with combined filters
    Given there are listings with the following details:
      | title                  | city      | price | description                    |
      | Cozy room near campus | New York  | 600   | Small furnished room           |
      | Affordable studio     | New York  | 800   | Furnished studio apartment     |
      | Budget room           | New York  | 500   | Shared room                    |
      | Luxury apartment      | New York  | 1500  | Furnished luxury apartment     |
    When I am on the search listings page
    And I fill in "City" with "New York"
    And I fill in "Min Price" with "600"
    And I fill in "Max Price" with "900"
    And I fill in "Keywords" with "furnished"
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Affordable studio"
    And I should not see "Budget room"
    And I should not see "Luxury apartment"

  Scenario: User searches with no matching results
    Given there are listings with the following details:
      | title                  | city      | price | description              |
      | Cozy room near campus | New York  | 600   | Small furnished room     |
      | Affordable studio     | Boston    | 800   | Studio apartment         |
    When I am on the search listings page
    And I fill in "City" with "Los Angeles"
    And I press "Search"
    Then I should see "No listings found matching your search criteria"

  Scenario: User searches with empty criteria shows all listings
    Given there are listings with the following details:
      | title                  | city      | price | description              |
      | Cozy room near campus | New York  | 600   | Small furnished room     |
      | Affordable studio     | Boston    | 800   | Studio apartment         |
      | Budget room           | Chicago   | 500   | Shared room              |
    When I am on the search listings page
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Affordable studio"
    And I should see "Budget room"

  Scenario: User searches by city with case-insensitive matching
    Given there are listings with the following details:
      | title                  | city      | price | description              |
      | Cozy room near campus | New York  | 600   | Small furnished room     |
      | Affordable studio     | new york  | 800   | Studio apartment         |
      | Budget room           | NEW YORK  | 500   | Shared room              |
    When I am on the search listings page
    And I fill in "City" with "new york"
    And I press "Search"
    Then I should see "Cozy room near campus"
    And I should see "Affordable studio"
    And I should see "Budget room"

