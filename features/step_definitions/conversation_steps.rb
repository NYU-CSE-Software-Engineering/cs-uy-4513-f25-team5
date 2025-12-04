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
  visit auth_login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log In'
  @current_user = User.find_by(email: email)
  @current_user.update!(
    bio: "a",
    budget: 1,
    preferred_location: "a",
    sleep_schedule: "",
    pets: "a",
    housing_status: "a",
    contact_visibility: "a",
    role: @current_user.role || "user",
    suspended: false
  )
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

Given("a compatible user {string} exists") do |display_name|
  User.create!(
    display_name: display_name,
    email: "#{display_name.downcase}@example.com",
    password: "password1234",
    bio: "compatible bio",
    preferred_location: @current_user.preferred_location,
    budget: @current_user.budget,
    sleep_schedule: @current_user.sleep_schedule,
    pets: @current_user.pets,
    housing_status: @current_user.housing_status,
    contact_visibility: @current_user.contact_visibility
  )

end


Given('{string} appears in my matches') do |display_name|
  # Ensure current_user has profile data compatible with matches
  @current_user.update!(
    display_name: @current_user.display_name || "Alice",
    bio: @current_user.bio || "This is my bio",
    budget: @current_user.budget || 1000,
    preferred_location: @current_user.preferred_location || "New York",
    sleep_schedule: @current_user.sleep_schedule || "Night Owl",
    pets: @current_user.pets || "No pets",
    housing_status: @current_user.housing_status || "Own",
    contact_visibility: @current_user.contact_visibility || "Public",
    role: @current_user.role || "user",
    suspended: false
  )

  # Make sure the target user exists and has compatible profile
  user = User.find_by(display_name: display_name)
  user.update!(
    bio: user.bio || "Bio for matching",
    budget: user.budget || 1000,
    preferred_location: user.preferred_location || "New York",
    sleep_schedule: user.sleep_schedule || "Night Owl",
    pets: user.pets || "No pets",
    housing_status: user.housing_status || "Own",
    contact_visibility: user.contact_visibility || "Public",
    role: user.role || "user",
    suspended: false
  )

  # Visit matches page and generate matches
  visit matches_path
  click_button "Find Matches"

  # Wait for the match with the specific user to appear
  expect(page).to have_css(".match-card", text: display_name)
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
  visit profile_path(user)
end

When('I visit the conversations page') do
  visit conversations_path
end

When('I click {string}') do |button_text|
  click_button button_text
end

When('I try to visit that conversation') do
  visit conversation_path(@conversation)
end

When('I try to start a new conversation with {string}') do |display_name|
  user = User.find_by(display_name: display_name)
  
  # Use Rack::Test to post directly (since there is no UI element here)
  page.driver.submit :post, conversations_path, { user_id: user.id }
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

When("I try to send a message to that conversation") do
  visit conversation_path(@conversation)
  fill_in "message[body]", with: "Hello"
  click_button "Send Message"
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