# Step definitions for user login and authentication feature

# Background step - reusing from create_listing_steps.rb
# Given('the test database is clean') is already defined

# Navigation steps
Given('I am on the signup page') do
  visit auth_register_path
end

Given('I am on the login page') do
  visit auth_login_path
end

Given('I am on the home page') do
  visit root_path
end

When('I am on the dashboard page') do
  visit dashboard_path
end

# User creation steps
Given('a user exists with email {string} and password {string}') do |email, password|
  @user_passwords ||= {}
  @user_passwords[email] = password
  User.create!(email: email, password: password, password_confirmation: password)
end

Given('I am logged in as {string}') do |email|
  password = @user_passwords[email]
  raise "Password for #{email} is not defined" if password.blank?

  visit auth_login_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Sign in'  # Updated to match actual button text

  @current_user = User.find_by(email: email)
end

# Form interaction steps - using standard Capybara methods
When('I fill in {string} with {string}') do |field, value|
  # Handle field name variations
  field_name = case field
  when 'Password confirmation'
    'Confirm Password'  # Match actual label
  else
    field
  end
  fill_in field_name, with: value
end

When('I press {string}') do |button|
  click_button button
end

# Assertion steps - checking page content
Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

# Assertion steps - checking current page
Then('I should be on the dashboard page') do
  expect(current_path).to eq(dashboard_path)
end

Then('I should be on the signup page') do
  expect(current_path).to eq(auth_register_path)
end

Then('I should be on the login page') do
  expect(current_path).to eq(auth_login_path)
end

Then('I should be on the home page') do
  expect(current_path).to eq(root_path)
end

Then('the {string} field should contain {string}') do |field_label, expected_value|
  field = find_field(field_label)
  expect(field.value).to eq(expected_value)
end

# Database assertion steps
Then('the user {string} should exist in the database') do |email|
  user = User.find_by(email: email)
  expect(user).not_to be_nil
end

# Authorization/access control steps
Then('I should not have access to protected pages') do
  visit dashboard_path
  expect(current_path).to eq(auth_login_path)
  expect(page).to have_content('Please sign in first.')
end

Given('I am not signed in') do
  page.driver.post(auth_logout_path)
end
