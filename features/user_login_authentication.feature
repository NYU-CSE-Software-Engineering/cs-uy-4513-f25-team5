Feature: User login and authentication
  As a student or newcomer to the city
  I want to securely log in to my RoomMate account
  So that I can access my profile and find compatible roommates

  Background:
    Given the test database is clean

  Scenario: User successfully registers a new account
    Given I am on the signup page
    When I fill in "Email" with "newuser@example.com"
    And I fill in "Password" with "securepass123"
    And I fill in "Password confirmation" with "securepass123"
    And I press "Sign up"
    Then I should be on the dashboard page
    And I should see "Welcome! You have successfully signed up."
    And the user "newuser@example.com" should exist in the database

  Scenario: User fails to register with an existing email
    Given a user exists with email "existing@example.com" and password "password123"
    And I am on the signup page
    When I fill in "Email" with "existing@example.com"
    And I fill in "Password" with "newpassword1"
    And I fill in "Password confirmation" with "newpassword1"
    And I press "Sign up"
    Then I should see "Email has already been taken"
    And I should be on the signup page

  Scenario: User fails to register with invalid email format
    Given I am on the signup page
    When I fill in "Email" with "invalid-email"
    And I fill in "Password" with "password123"
    And I fill in "Password confirmation" with "password123"
    And I press "Sign up"
    Then I should see "Email is invalid"
    And I should be on the signup page

  Scenario: User fails to register with mismatched passwords
    Given I am on the signup page
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "password123"
    And I fill in "Password confirmation" with "differentpass1"
    And I press "Sign up"
    Then I should see "Password confirmation doesn't match"
    And I should be on the signup page

  Scenario: User fails to register with a weak password
    Given I am on the signup page
    When I fill in "Email" with "weakpass@example.com"
    And I fill in "Password" with "short1"
    And I fill in "Password confirmation" with "short1"
    And I press "Sign up"
    Then I should see "Password must be at least 10 characters and include both letters and numbers"
    And I should be on the signup page

  Scenario: User successfully logs in with valid credentials
    Given a user exists with email "user@example.com" and password "mypassword1"
    And I am on the login page
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "mypassword1"
    And I press "Log in"
    Then I should be on the dashboard page
    And I should see "Successfully logged in"

  Scenario: User fails to log in with incorrect password
    Given a user exists with email "user@example.com" and password "correctpass1"
    And I am on the login page
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "wrongpassword1"
    And I press "Log in"
    Then I should see "Invalid email or password"
    And I should be on the login page
    And the "Email" field should contain "user@example.com"

  Scenario: User fails to log in with non-existent email
    Given I am on the login page
    When I fill in "Email" with "nonexistent@example.com"
    And I fill in "Password" with "somepassword"
    And I press "Log in"
    Then I should see "Invalid email or password"
    And I should be on the login page

  Scenario: User successfully logs out
    Given a user exists with email "user@example.com" and password "password123"
    And I am logged in as "user@example.com"
    When I am on the dashboard page
    And I press "Log out"
    Then I should be on the home page
    And I should see "Successfully logged out"
    And I should not have access to protected pages

  @todo_auth
  # TODO: This scenario should pass once real session-based authentication replaces the demo bootstrap user.
  Scenario: Unauthenticated user is redirected when visiting the profile page
    Given I am not signed in
    When I visit my profile page
    Then I should be redirected to the login page
