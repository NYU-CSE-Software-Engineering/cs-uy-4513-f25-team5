Feature: User creates and submits a report
  As a signed-in user
  I want to report inappropriate behavior or profiles
  In order to maintain a safe environment

  Background:
    Given an admin exists
    And at least one report exists in the system

  Scenario: Successfully submitting a report
    Given I am signed in
    And I am viewing another user's profile
    When I press "Report User"
    And I select "Harassment" from the report type list
    And I enter "User sent threatening messages" in the description field
    And I submit the report
    Then I should see a confirmation message
    And the report should be saved in the system

  Scenario: Submitting a report with missing fields
    Given I am signed in
    And I am viewing another user's profile
    When I press "Report User"
    And I submit the report without selecting a type
    Then I should see an error message
    And the report should not be created

  Scenario: Admin views all reports
    Given I am signed in as an admin
    When I visit the admin reports page
    Then I should see a list of all submitted reports
    And each report should display the reporter, reported user, and report type