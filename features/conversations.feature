# features/conversations.feature
Feature: Conversations and Messaging
  As a user
  I want to have conversations with other users
  So that I can communicate about matches and listings

  Background:
    Given the following users exist:
      | email              | password  | display_name |
      | bob@example.com    | password1234 | Bob          |
      | carol@example.com  | password1234 | Carol        |

  Scenario: User views empty conversations list
    Given I am a signed-in user named "Alice"
    When I visit the conversations page
    Then I should see "You don't have any conversations yet"

  Scenario: User starts a new conversation from matches page
    Given I am a signed-in user named "Alice"
    And a compatible user "UH" exists
    And I am on the matches page
    And "UH" appears in my matches
    When I start a conversation with "UH"
    Then I should be on the conversation page with "UH"
    And I should see "Conversation started"

  Scenario: Polling for new messages
    Given I am a signed-in user named "Alice"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I poll for new messages since "2.minutes.ago"
    And "Bob" sends a new message "Hello from Bob"
    And I poll for new messages again
    Then the poll response should contain the new message
    And the message should have:
      | field           | value           |
      | body            | Hello from Bob  |
      | user_name       | Bob             |
      | is_current_user | false           |

  Scenario: Guest user cannot access conversations
    Given I am not logged in
    When I try to visit the conversations page
    Then I should be redirected to the login page
    And I should see "You must be logged in to access conversations"

  Scenario: Conversation shows last message timestamp
    Given I am a signed-in user named "Alice"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    And the conversation has a message from "bob@example.com" sent "5.minutes.ago"
    When I visit the conversations page
    Then I should see "5 minutes ago" near "Bob"

  Scenario: User sees avatar in conversation list
    Given I am a signed-in user named "Alice"
    And "Bob" has an avatar
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversations page
    Then I should see "Bob"'s avatar

  Scenario: User sees avatar placeholder when no avatar exists
    Given I am a signed-in user named "Alice"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversations page
    Then I should see the avatar placeholder "B" for "Bob"

  Scenario: Multiple messages display correctly
    Given I am a signed-in user named "Alice"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    And the conversation has messages:
      | sender            | body                    |
      | bob@example.com   | Hi Alice                |
      | alice@example.com | Hi Bob                  |
      | bob@example.com   | How's your day?         |
      | alice@example.com | Great! Yours?           |
      | bob@example.com   | Pretty good!            |
    When I visit the conversation with "Bob"
    Then I should see all 5 messages in order

  Scenario: Navigation back to conversations list
    Given I am a signed-in user named "Alice"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with "Bob"
    And I go to conversations
    Then I should be on the conversations page
    
  Scenario: Starting a conversation with a non-existent user
    Given I am a signed-in user named "Alice"
    When I try to start a conversation with a non-existent user with id 9999
    Then I should be redirected to the home page
    And I should see "User not found"

  Scenario: Starting a conversation with yourself
    Given I am a signed-in user named "Alice"
    When I try to start a conversation with "Alice"
    Then I should be redirected to the home page