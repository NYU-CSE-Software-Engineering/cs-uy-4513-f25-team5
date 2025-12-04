# features/conversations.feature
Feature: Conversations and Messaging
  As a user
  I want to have conversations with other users
  So that I can communicate about matches and listings

  Background:
    Given the following users exist:
      | email              | password  | display_name |
      | alice@example.com  | password1234 | Alice        |
      | bob@example.com    | password1234 | Bob          |
      | carol@example.com  | password1234 | Carol        |

  Scenario: User views their conversations list
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    And the conversation has messages:
      | sender            | body                |
      | bob@example.com   | Hey Alice!          |
      | alice@example.com | Hi Bob!             |
    When I visit the conversations page
    Then I should see "My Conversations"
    And I should see "Bob"
    And I should see "Hi Bob!"

  Scenario: User views empty conversations list
    Given I am logged in as "alice@example.com" with password "password1234"
    When I visit the conversations page
    Then I should see "You don't have any conversations yet"

  Scenario: User starts a new conversation from matches page
    Given I am logged in as "alice@example.com" with password "password1234"
    And a compatible user "UH" exists
    And I am on the matches page
    And "UH" appears in my matches
    When I click "Start Conversation" for "UH"
    Then I should be on the conversation page with "UH"
    And I should see "Conversation started"

  Scenario: User views a conversation
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    And the conversation has messages:
      | sender            | body                  | created_at        |
      | bob@example.com   | Hey, how are you?     | 2.minutes.ago     |
      | alice@example.com | I'm good, thanks!     | 1.minute.ago      |
    When I visit the conversation with "Bob"
    Then I should see "Bob" in the header
    And I should see "Hey, how are you?"
    And I should see "I'm good, thanks!"
    And the messages should be in chronological order

  Scenario: User sends a message in a conversation
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with "Bob"
    And I fill in "message[body]" with "What's your budget range?"
    And I click "Send Message"
    Then I should see "Message sent"
    And I should see "What's your budget range?"

  Scenario: User cannot send empty message
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with "Bob"
    And I fill in "message[body]" with ""
    And I click "Send Message"
    Then I should see "Message could not be sent"

  Scenario: User cannot view another user's conversation
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "bob@example.com" and "carol@example.com"
    When I try to visit that conversation
    Then I should be redirected to the conversations page
    And I should see "You don't have access to this conversation"

  Scenario: Starting a conversation with existing conversation redirects to it
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I try to start a new conversation with "Bob"
    Then I should be on the existing conversation page with "Bob"

  Scenario: Polling for new messages
    Given I am logged in as "alice@example.com" with password "password1234"
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
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    And the conversation has a message from "bob@example.com" sent "5.minutes.ago"
    When I visit the conversations page
    Then I should see "5 minutes ago" near "Bob"

  Scenario: User sees avatar in conversation list
    Given I am logged in as "alice@example.com" with password "password1234"
    And "Bob" has an avatar
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversations page
    Then I should see "Bob"'s avatar

  Scenario: User sees avatar placeholder when no avatar exists
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversations page
    Then I should see the avatar placeholder "B" for "Bob"

  Scenario: Multiple messages display correctly
    Given I am logged in as "alice@example.com" with password "password1234"
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
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "alice@example.com" and "bob@example.com"
    When I visit the conversation with "Bob"
    And I go to conversations
    Then I should be on the conversations page

  Scenario: Unauthorized poll request returns error
    Given I am logged in as "alice@example.com" with password "password1234"
    And a conversation exists between "bob@example.com" and "carol@example.com"
    When I try to poll that conversation
    Then I should receive a JSON error "Unauthorized"
    And the response status should be 403