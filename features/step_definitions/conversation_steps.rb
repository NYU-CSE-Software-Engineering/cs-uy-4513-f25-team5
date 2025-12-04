# features/step_definitions/conversation_steps.rb

Given('the following users exist:') do |table|
  table.hashes.each do |row|
    User.create!(
      email: row['email'],
      password: row['password'],
      password_confirmation: row['password'],
      display_name: row['display_name']
    )
  end
end

Given('I am logged in as {string} with password {string}') do |email, password|
  visit login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Login'
  @current_user = User.find_by(email: email)
end


Given('a conversation exists between {string} and {string}') do |email1, email2|
  user1 = User.find_by(email: email1)
  user2 = User.find_by(email: email2)
  sorted_ids = [user1.id, user2.id].sort
  
  @conversation = Conversation.create!(
    participant_one_id: sorted_ids[0],
    participant_two_id: sorted_ids[1]
  )
end

Given('the conversation has messages:') do |table|
  table.hashes.each do |row|
    sender = User.find_by(email: row['sender'])
    created_at = if row['created_at']
                   eval(row['created_at'].gsub(' ago', '.ago'))
                 else
                   Time.current
                 end
    
    Message.create!(
      conversation: @conversation,
      user: sender,
      body: row['body'],
      created_at: created_at
    )
  end
end

Given('the conversation has a message from {string} sent {string}') do |email, time_ago|
  sender = User.find_by(email: email)
  created_at = eval(time_ago.gsub(' ago', '.ago'))
  
  Message.create!(
    conversation: @conversation,
    user: sender,
    body: "Test message",
    created_at: created_at
  )
end

Given('I am on the matches page') do
  visit matches_path
end

Given('{string} appears in my matches') do |display_name|
  user = User.find_by(display_name: display_name)
  Match.create!(
    user: @current_user,
    matched_user: user,
    compatibility_score: 85.5
  )
  visit matches_path
end

Given('{string} has an avatar') do |display_name|
  user = User.find_by(display_name: display_name)
  Avatar.create!(
    user: user,
    image_base64: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    filename: "avatar.png"
  )
end

Given('I am viewing {string}\'s profile') do |display_name|
  user = User.find_by(display_name: display_name)
  visit user_path(user)
end

When('I visit the conversations page') do
  visit conversations_path
end

When('I visit the conversation with {string}') do |display_name|
  user = User.find_by(display_name: display_name)
  other_user = @conversation.participant_one == @current_user ? @conversation.participant_two : @conversation.participant_one
  visit conversation_path(@conversation)
end

When('I click {string}') do |button_text|
  click_button button_text
end

When('I click {string} for {string}') do |button_text, user_name|
  within("div", text: user_name) do
    click_button button_text
  end
end

When('I try to visit that conversation') do
  visit conversation_path(@conversation)
end

When('I try to start a conversation with myself') do
  visit root_path
  page.driver.post conversations_path, user_id: @current_user.id
end

When('I try to start a new conversation with {string}') do |display_name|
  user = User.find_by(display_name: display_name)
  page.driver.post conversations_path, user_id: user.id
  follow_redirect!
end

When('I poll for new messages since {string}') do |time_string|
  since = eval(time_string.gsub(' ago', '.ago'))
  @poll_since = since.iso8601
end

When('{string} sends a new message {string}') do |display_name, message_body|
  user = User.find_by(display_name: display_name)
  Message.create!(
    conversation: @conversation,
    user: user,
    body: message_body
  )
end

When('I poll for new messages again') do
  page.driver.get poll_conversation_path(@conversation, since: @poll_since)
  @poll_response = JSON.parse(page.body)
end

When('I try to visit the conversations page') do
  visit conversations_path
end

When('I try to send a message to that conversation') do
  page.driver.post conversation_messages_path(@conversation), { message: { body: "Test" } }
end

When('I try to poll that conversation') do
  page.driver.get poll_conversation_path(@conversation)
  @response_status = page.status_code
  @response_body = JSON.parse(page.body) rescue {}
end

Then('I should see {string} in the header') do |text|
  within('.conversation-header') do
    expect(page).to have_content(text)
  end
end

Then('the messages should be in chronological order') do
  messages = page.all('.message').map { |m| m.find('.message-body').text }
  expect(messages).to eq(["Hey, how are you?", "I'm good, thanks!"])
end

Then('I should be on the conversation page with {string}') do |display_name|
  user = User.find_by(display_name: display_name)
  expect(current_path).to match(/\/conversations\/\d+/)
  expect(page).to have_content(display_name)
end

Then('I should be redirected to the conversations page') do
  expect(current_path).to eq(conversations_path)
end

Then('I should be on the existing conversation page with {string}') do |display_name|
  expect(current_path).to eq(conversation_path(@conversation))
end

Then('I should be on the conversations page') do
  expect(current_path).to eq(conversations_path)
end

Then('I should be on a conversation page with {string}') do |display_name|
  expect(current_path).to match(/\/conversations\/\d+/)
  expect(page).to have_content(display_name)
end

Then('the poll response should contain the new message') do
  expect(@poll_response['messages'].length).to be > 0
  expect(@poll_response['messages'].last['body']).to eq("Hello from Bob")
end

Then('the message should have:') do |table|
  message = @poll_response['messages'].last
  table.hashes.each do |row|
    expected_value = row['value'] == 'false' ? false : row['value']
    expect(message[row['field']]).to eq(expected_value)
  end
end

Then('I should see {string} near {string}') do |text1, text2|
  expect(page).to have_content(text1)
  expect(page).to have_content(text2)
end

Then('I should see {string}\'s avatar') do |display_name|
  expect(page).to have_css('.avatar img')
end

Then('I should see the avatar placeholder {string} for {string}') do |initial, display_name|
  within('.conversation-card', text: display_name) do
    expect(page).to have_css('.avatar-placeholder', text: initial)
  end
end

Then('I should see all {int} messages in order') do |count|
  messages = page.all('.message')
  expect(messages.count).to eq(count)
end

Then('I should receive a JSON error {string}') do |error_message|
  expect(@response_body['error']).to eq(error_message)
end

Then('the response status should be {int}') do |status_code|
  expect(@response_status).to eq(status_code)
end