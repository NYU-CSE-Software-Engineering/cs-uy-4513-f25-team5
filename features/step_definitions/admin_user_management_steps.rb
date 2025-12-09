Given('I create the following users:') do |table|
  table.hashes.each do |user_attrs|
    # Ensure password meets validation requirements (10+ chars, letters + numbers)
    password = user_attrs['password'] || 'password123'
    if password.length < 10 || !password.match?(/[a-zA-Z]/) || !password.match?(/\d/)
      password = 'password123' # Default valid password
    end
    User.create!(user_attrs.merge('password' => password, 'password_confirmation' => password))
  end
end

Given('I am signed in as an admin') do
  @current_user = User.find_by(role: 'admin')
  visit auth_login_path
  fill_in 'Email', with: @current_user.email
  # Use the password that was set during creation
  fill_in 'Password', with: 'password123'  # Default valid password
  click_button 'Sign in'  # Updated to match actual button text
end

Given('I am signed out') do
  visit destroy_user_session_path
end

Given('I am signed in as a regular user with email {string}') do |email|
  @current_user = User.find_by(email: email)
  visit auth_login_path
  fill_in 'Email', with: @current_user.email
  fill_in 'Password', with: 'password123'  # Valid password
  click_button 'Sign in'  # Updated to match actual button text
end

Given('the user {string} has created a listing titled {string}') do |email, title|
  user = User.find_by(email: email)
  Listing.create!(
    title: title,
    description: 'Test listing',
    price: 500,
    city: 'New York',
    user: user
  )
end

When('I visit the admin users page') do
  visit admin_users_path
end

When('I attempt to visit the admin users page') do
  visit admin_users_path
end

When('I suspend the user {string}') do |email|
  user = User.find_by(email: email)
  visit admin_users_path
  within("[data-user-id='#{user.id}']") do
    click_button 'Suspend'
  end
end

When('I delete the user {string}') do |email|
  user = User.find_by(email: email)
  visit admin_users_path
  within("[data-user-id='#{user.id}']") do
    click_button 'Delete'
  end
end

When('I attempt to delete the user {string}') do |email|
  user = User.find_by(email: email)
  visit admin_users_path
  within("[data-user-id='#{user.id}']") do
    click_button 'Delete'
  end
end

Then('I should see a list of all users:') do |table|
  table.hashes.each do |user_data|
    expect(page).to have_content(user_data['email'])
    expect(page).to have_content(user_data['display_name'])
  end
end

Then('the user {string} should be suspended') do |email|
  user = User.find_by(email: email)
  expect(user.reload.suspended).to be true
end

Then('I should see a confirmation message {string}') do |message|
  expect(page).to have_content(message)
end

Then('the user {string} should not exist in the database') do |email|
  user = User.find_by(email: email)
  expect(user).to be_nil
end

Then('the listing {string} should not exist in the database') do |title|
  listing = Listing.find_by(title: title)
  expect(listing).to be_nil
end

Then('I should see an error message {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should not see the admin users list') do
  expect(page).not_to have_css('[data-testid="admin-users-table"]')
end

Then('the user {string} should still exist in the database') do |email|
  user = User.find_by(email: email)
  expect(user).not_to be_nil
end
