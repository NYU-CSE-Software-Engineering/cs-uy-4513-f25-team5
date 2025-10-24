Feature: Chat with matched users
  As a RoomMatch user
  I want to message my matched roommates
  So that I can coordinate housing plans and get to know them better
  
  Background:
    Given the matching system is available

  Scenario: User views their conversations list
    Given I am a signed-in user named "Mohammed"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven"
    When I visit the conversations page
    Then I should see "Steven" in my conversations list

  Scenario: User opens an existing conversation with messages
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven" containing messages:
      | sender   | body                               |
      | Mohammad | Hey, still looking for a roommate? |
      | Steven   | Yes! Let's chat                    |
    When I visit the conversation with "Steven"
    Then I should see messages in chronological order:
      | sender   | body                               |
      | Mohammad | Hey, still looking for a roommate? |
      | Steven   | Yes! Let's chat                    |
    And the message "Hey, still looking for a roommate?" should show "Mohammad" as sender
    And the message "Yes! Let's chat" should show "Steven" as sender
    And each message should have a timestamp

  Scenario: User sends a valid message to matched user
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven"
    When I visit the conversation with "Steven"
    And I fill in "message_body" with "When are you available to meet?"
    And I click "Send"
    Then I should see "When are you available to meet?" in the conversation
    And the message should have my name "Mohammad" displayed
    And the message should have a timestamp

  Scenario: User tries to send an empty message
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven"
    When I visit the conversation with "Steven"
    And I fill in "message_body" with ""
    And I click "Send"
    Then I should see a validation error
    And no new message should be created

  Scenario: User cannot message unmatched users
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am not matched with "Steven"
    When I try to start a conversation with "Steven"
    Then I should be denied access
    And I should see "You must be matched to send messages"

  Scenario: User cannot view someone else's conversation
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And another user "Charlie" exists
    And "Steven" is matched with "Charlie"
    And "Steven" has a conversation with "Charlie"
    When I try to visit the conversation between "Steven" and "Charlie"
    Then I should be denied access
    And I should see "You are not authorized"

  Scenario: User blocks another user in conversation
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven"
    When I visit the conversation with "Steven"
    And I click "Block User"
    Then "Steven" should be blocked
    And I should see "User has been blocked"
    And I should not be able to send messages to "Steven"

  Scenario: User reports another user in conversation
    Given I am a signed-in user named "Mohammad"
    And another user "Steven" exists
    And I am matched with "Steven"
    And I have a conversation with "Steven"
    When I visit the conversation with "Steven"
    And I click "Report User"
    And I fill in the report reason with "Inappropriate behavior"
    And I submit the report
    Then the report should be created
    And I should see "Report submitted successfully"
