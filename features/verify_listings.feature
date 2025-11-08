Feature: Verify housing listings
  As a Community Verifier
  I want to review and verify housing listings
  So that members can trust verified properties

  Background:
    Given I am logged in as a Community Verifier
    And the following listings exist:
      | title                       | owner_email        | status     | verification_requested |
      | Sunny Room in Brooklyn      | alice@example.com  | pending    | true                   |
      | Cozy Apartment in Manhattan | bob@example.com    | published  | false                  |

  Scenario: Approve a listing verification request
    Given a listing has requested verification
    When I navigate to the verification requests page
    And I open the "Sunny Room in Brooklyn" listing details
    And I mark the listing as verified
    Then I should see the listing marked as "Verified"
    And the member should see a "Verified" badge on the listing page

  Scenario: Listing without verification request does not appear
    When I navigate to the verification requests page
    Then I should not see "Cozy Apartment in Manhattan"

  Scenario: Verified badge only for verified listings
    Given a listing is marked as verified
    When a member views the listing
    Then they should see a "Verified" badge
    When a member views an unverified listing
    Then they should not see a "Verified" badge
