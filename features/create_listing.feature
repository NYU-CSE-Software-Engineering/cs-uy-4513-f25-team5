Feature: Create a housing listing
  As a signed-in user
  I want to create a housing listing
  So that I can advertise an available room or property

  Background:
    Given the test database is clean
    And I am a signed-in user

  Scenario: User creates a listing with valid information
    When I create a listing with:
      | title       | Cozy room near campus                |
      | description | Small furnished room, utilities included |
      | price       | 600                                  |
      | city        | New York                             |
    Then the listing "Cozy room near campus" should exist in the database
    And the listing should belong to the signed-in user
    And I should see a confirmation message "Listing was successfully created"

  Scenario: User fails to create a listing without a title
    When I attempt to create a listing with:
      | title       |                                      |
      | description | No title provided                     |
      | price       | 500                                  |
      | city        | Boston                               |
    Then the listing should not be saved
    And I should see a validation error "Title can't be blank"

  Scenario: User fails to create a listing without a price
    When I attempt to create a listing with:
      | title       | Affordable studio                     |
      | description | Cozy studio near downtown             |
      | price       |                                      |
      | city        | Chicago                               |
    Then the listing should not be saved
    And I should see a validation error "Price can't be blank"

  Scenario: User fails to create a listing with negative price
    When I attempt to create a listing with:
      | title       | Budget room                            |
      | description | Cheap room for students               |
      | price       | -100                                  |
      | city        | San Francisco                         |
    Then the listing should not be saved
    And I should see a validation error "Price must be greater than 0"
