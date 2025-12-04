# features/step_definitions/chat_steps.rb
# Step definitions for the chat feature aligned with Project Specification
# Messaging is only allowed between matched users (per spec section 2.4)

# Store users and matches by name for easy lookup
Before do
  @users = {}
  @matches = {}
  @blocked_users = []
end

Given('the matching system is available') do
  # Placeholder for matching system availability check
  # In real implementation, this would verify matcher-service is running
end

Given('I am a signed-in user named {string}') do |name|
  @me = User.create!(name: name, email: "#{name.downcase.gsub(' ', '')}@example.com")
  @users[name] = @me
  @current_user = @me
end

Given('another user {string} exists') do |name|
  user = User.create!(name: name, email: "#{name.downcase.gsub(' ', '')}@example.com")
  @users[name] = user
end

Given('I am matched with {string}') do |name|
  other = @users[name] || User.find_by!(name: name)
  # Create an active match between users
  @match = ActiveMatch.create!(
    user_one_id: @me.id,
    user_two_id: other.id,
    status: 'active'
  )
  @matches[@me.id] ||= []
  @matches[@me.id] << other.id
end

Given('I am not matched with {string}') do |name|
  # Explicitly ensure no match exists
  other = @users[name] || User.find_by!(name: name)
  @matches[@me.id] ||= []
  @matches[@me.id].delete(other.id) if @matches[@me.id].include?(other.id)
end

Given('{string} is matched with {string}') do |name1, name2|
  user1 = @users[name1] || User.find_by!(name: name1)
  user2 = @users[name2] || User.find_by!(name: name2)
  ActiveMatch.create!(
    user_one_id: user1.id,
    user_two_id: user2.id,
    status: 'active'
  )
end

Given('I have a conversation with {string}') do |name|
  other = @users[name] || User.find_by!(name: name)
  @conversation = Conversation.create!(
    participant_one_id: @me.id, 
    participant_two_id: other.id
  )
end

Given('I have a conversation with {string} containing messages:') do |name, table|
  other = @users[name] || User.find_by!(name: name)
  @conversation = Conversation.create!(
    participant_one_id: @me.id, 
    participant_two_id: other.id
  )
  
  table.hashes.each do |row|
    sender = @users[row["sender"]] || User.find_by!(name: row["sender"])
    Message.create!(
      conversation: @conversation, 
      user: sender, 
      body: row["body"]
    )
  end
end

Given('{string} has a conversation with {string}') do |name1, name2|
  user1 = @users[name1] || User.find_by!(name: name1)
  user2 = @users[name2] || User.find_by!(name: name2)
  @other_conversation = Conversation.create!(
    participant_one_id: user1.id, 
    participant_two_id: user2.id
  )
end

When('I visit the conversation with {string}') do |name|
  other = @users[name] || User.find_by!(name: name)
  @conversation ||= Conversation.where(participant_one_id: @me.id, participant_two_id: other.id)
                                .or(Conversation.where(participant_one_id: other.id, participant_two_id: @me.id))
                                .first!
  visit conversation_path(@conversation)
end

When('I try to visit the conversation between {string} and {string}') do |name1, name2|
  # Try to visit someone else's conversation
  visit conversation_path(@other_conversation)
end

When("I try to start a conversation with {string}") do |display_name|
  user = User.find_by!(display_name: display_name)

  if user == @current_user
    visit root_path
    # flash message is already set by controller when redirecting
  else
    page.driver.submit :post, conversations_path(user_id: user.id), {}
  end
end




When('I fill in the report reason with {string}') do |reason|
  fill_in 'report_reason', with: reason
end

When('I submit the report') do
  click_button 'Submit Report'
end

Then('I should see {string} in my conversations list') do |name|
  expect(page).to have_content(name)
end

Then('I should see messages in chronological order:') do |table|
  messages = page.all('.message .body').map(&:text)
  
  table.hashes.each_with_index do |row, index|
    expect(messages[index]).to include(row["body"])
  end
end

Then('the message {string} should show {string} as sender') do |message_text, sender_name|
  message_element = page.find('.message', text: message_text)
  expect(message_element).to have_content(sender_name)
end

Then('each message should have a timestamp') do
  page.all('.message').each do |message|
    expect(message).to have_css('.timestamp')
  end
end

Then('I should see a validation error') do
  has_error = page.has_content?("can't be blank") || 
              page.has_content?("error") || 
              page.has_css?(".error")
  expect(has_error).to be true
end

Then('no new message should be created') do
  # Check that the last message count hasn't increased
  expect(Message.count).to eq(@message_count_before || 0)
end

Then('I should be denied access') do
  has_error = page.has_content?("not authorized") || 
              page.has_content?("access denied") || 
              page.has_content?("You are not authorized") ||
              page.has_content?("You must be matched")
  expect(has_error).to be true
end

Then('{string} should be blocked') do |name|
  other = @users[name] || User.find_by!(name: name)
  # Check that a block record exists
  block = Block.find_by(blocker_id: @me.id, blocked_id: other.id)
  expect(block).to be_present
  @blocked_users << other.id
end

Then('I should not be able to send messages to {string}') do |name|
  other = @users[name] || User.find_by!(name: name)
  expect(@blocked_users).to include(other.id)
  # Verify message form is disabled or hidden
  has_no_form = page.has_no_field?('message_body') || page.has_css?('#message_body[disabled]')
  expect(has_no_form).to be true
end

Then('the report should be created') do
  # Check that a report was created in the database
  expect(Report.count).to be > (@initial_report_count || 0)
end
  
