# features/step_definitions/message_steps.rb
# features/step_definitions/message_steps.rb

When('I visit the conversation with email {string}') do |email|
  other_user = User.find_by(email: email)
  user1_id = @current_user.id
  user2_id = other_user.id
  sorted_ids = [user1_id, user2_id].sort
  
  conversation = Conversation.find_by(
    participant_one_id: sorted_ids[0],
    participant_two_id: sorted_ids[1]
  )
  
  visit conversation_path(conversation)
  @conversation = conversation
end

Then('I should be on the conversations index page') do
  expect(current_path).to eq(conversations_path)
end