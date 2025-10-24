Feature: Manage existing listings
  As a signed-in user
  I want to edit and delete my listings
  So that I can keep my property information accurate and remove unavailable listings

  Background:
    Given I am a signed-in user
    And I have a listing titled "Cozy Studio Apartment"

  Scenario: User succesfully edits listing
    When I visit the edit page for "Cozy Studio Apartment"
    And I fill in "description" with "Recently renovated and near NYU campus."
    And I fill in "price" with "950"
    And I press "Save changes"
    Then I should see the message "Listing was successfully updated."
    And I should see "Recently renovated and near NYU campus." on the listings page
    And I should see "950" on the listings page

  Scenario: User fails to edit listing with invalid data
    When I visit the edit page for "Cozy Studio Apartment"
    And I fill in "title" with ""
    And I fill in "price" with "-1000"
    And I press "Save changes"
    Then I should see a validation error message
    And the listing details should remain unchanged

  Scenario: User successfully deletes listing
    When I click "Delete" for "Cozy Studio Apartment"
    Then I should see the message "Listing was successfully deleted."
    And I should not see "Cozy Studio Apartment" on my listings page

  Scenario: User attempts to edit another user's listing
    Given another user has a listing titled "Luxury Loft Midtown"
    When I visit the edit page for "Luxury Loft Midtown"
    Then I should see an authorization error message