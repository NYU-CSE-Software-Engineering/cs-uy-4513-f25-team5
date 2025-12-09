Feature: Admin user management
  As an administrator
  I want to manage user accounts
  So that I can maintain platform safety and remove users who violate policies

  Background:
    Given the test database is clean
    And I create the following users:
      | email              | password  | display_name | role   |
      | admin@example.com  | admin123  | Admin User   | admin  |
      | john@example.com   | password  | John Doe     | member |
      | jane@example.com   | password  | Jane Smith   | member |
    And I am signed in as an admin

  @wip
  Scenario: Admin views all users
    When I visit the admin users page
    Then I should see a list of all users:
      | email              | display_name |
      | admin@example.com  | Admin User   |
      | john@example.com   | John Doe     |
      | jane@example.com   | Jane Smith   |

  Scenario: Admin suspends a user account
    When I suspend the user "john@example.com"
    Then the user "john@example.com" should be suspended
    And I should see a confirmation message "User john@example.com has been suspended"

  Scenario: Admin deletes a user account
    Given the user "jane@example.com" has created a listing titled "Cozy Apartment"
    When I delete the user "jane@example.com"
    Then the user "jane@example.com" should not exist in the database
    And the listing "Cozy Apartment" should not exist in the database
    And I should see a confirmation message "User jane@example.com has been deleted"

  Scenario: Non-admin user is denied access to admin panel
    Given I am signed out
    And I am signed in as a regular user with email "john@example.com"
    When I attempt to visit the admin users page
    Then I should see an error message "Access denied"
    And I should not see the admin users list

  Scenario: Admin cannot delete their own account
    When I attempt to delete the user "admin@example.com"
    Then the user "admin@example.com" should still exist in the database
    And I should see an error message "Cannot delete your own admin account"
