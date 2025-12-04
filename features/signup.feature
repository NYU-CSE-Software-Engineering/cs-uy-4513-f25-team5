Feature: User signup

  Scenario: User visits the signup page
    When I visit the signup page
    Then I should see "Sign Up"

  Scenario: User signs up successfully
    When I sign up with:
      | email                 | test1@example.com |
      | password              | password123       |
      | password_confirmation | password123       |
    Then I should be redirected to the dashboard
    And I should see "Welcome! You have successfully signed up."

  Scenario: Signup fails due to missing password
    When I sign up with:
      | email                 | test2@example.com |
      | password              |                   |
      | password_confirmation |                   |
    Then I should see "Password can't be blank"

  Scenario: Signup fails due to mismatched password confirmation
    When I sign up with:
      | email                 | test3@example.com |
      | password              | password123       |
      | password_confirmation | wrongpass         |
    Then I should see "Password confirmation doesn't match Password"
