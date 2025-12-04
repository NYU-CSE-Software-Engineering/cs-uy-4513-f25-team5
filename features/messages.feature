# features/messages.feature
Feature: Messaging between users
  As a logged-in user
  I want to send messages in conversations
  So that I can communicate with other users

  Background:
    Given the test database is clean
    And a user exists with email "alice@example.com" and password "password1234"
    And a user exists with email "bob@example.com" and password "password1234"
    And a user exists with email "carol@example.com" and password "password1234"

  Scenario: User sends a message in their conversation
    Given I am logged in as "alice@example.com"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with email "bob@example.com"
    And I fill in "message[body]" with "Hello Bob, how are you?"
    And I press "Send Message"
    Then I should see "Hello Bob, how are you?"
    # Remove: And I should see "Message sent."

  Scenario: User cannot send empty message
    Given I am logged in as "alice@example.com"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with email "bob@example.com"
    And I fill in "message[body]" with ""
    And I press "Send Message"
    Then I should see "No messages yet"

  Scenario: User sends multiple messages in a conversation
    Given I am logged in as "alice@example.com"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with email "bob@example.com"
    And I fill in "message[body]" with "First message"
    And I press "Send Message"
    Then I should see "First message"
    When I fill in "message[body]" with "Second message"
    And I press "Send Message"
    Then I should see "Second message"

  Scenario: User sees their sent messages in the conversation
    Given I am logged in as "alice@example.com"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with email "bob@example.com"
    And I fill in "message[body]" with "My test message"
    And I press "Send Message"
    When I visit the conversation with email "bob@example.com"
    Then I should see "My test message"

  Scenario: User cannot access someone else's conversation
    Given I am logged in as "alice@example.com"
    And a conversation exists between "bob@example.com" and "carol@example.com"
    When I POST to create a message in that conversation
    Then I should be redirected to the conversations page
    And I should see "You don't have access"

  Scenario: Message fails to save due to validation error
    Given I am logged in as "alice@example.com"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with email "bob@example.com"
    And I fill in "message[body]" with ""
    And I press "Send Message"
    Then I should see "Message could not be sent."

  Scenario: User must be logged in to send a message
    When I POST to create a message without being logged in
    Then I should be redirected to the login page
    And I should see "You must be logged in."
