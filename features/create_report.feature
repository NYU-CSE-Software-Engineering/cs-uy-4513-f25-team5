Feature: User creates and submits a report
  As a signed-in user
  I want to report inappropriate behavior or profiles
  In order to maintain a safe environment

  Background:
    Given an admin exists
    And at least one report exists in the system
    And a reporter user exists

  Scenario: Successfully submitting a report
    Given I am on the "New Reports" page
    When I enter "offending_user@example.com" in the username field
    And I select "Harassment" from the report type list
    And I enter "User sent threatening messages" in the description field
    And I press the submit button
    And the report should be saved in the system

  Scenario: Submitting a report with missing fields
    Given I am on the "New Reports" page
    When I enter "offending_user@example.com" in the username field
    And I submit the report without selecting a type
    Then I should see an error message stating report type can't be blank

  Scenario: Submitting a report for a non-existent user
    Given I am on the "New Reports" page
    When I enter "unknown_user@example.com" in the username field
    And I select "Harassment" from the report type list
    And I enter "Inappropriate behavior" in the description field
    And I press the submit button
    Then I should see an error message stating the user does not exist

  Scenario: Admin views all reports
    Given I visit the admin reports page as an admin
    Then I should see a list of all submitted reports
    And each report should display the reporter, reported user, and report type