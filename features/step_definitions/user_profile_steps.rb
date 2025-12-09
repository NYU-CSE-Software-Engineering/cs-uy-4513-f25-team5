Given('I have a profile with:') do |table|
  attributes = table.rows_hash.transform_values(&:strip)
  @user ||= User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
  @user.update!(attributes.transform_keys(&:to_sym))
  @previous_profile_snapshot = attributes.transform_values(&:to_s)
end

When('I visit my profile page') do
  visit profile_path
end

Then('I should see my profile information:') do |table|
  table.rows_hash.each do |field, value|
    # Handle case-insensitive matching for normalized fields
    if ['preferred_location', 'sleep_schedule', 'pets', 'housing_status'].include?(field.downcase)
      expect(page).to have_content(/#{Regexp.escape(value.strip)}/i)
    else
      expect(page).to have_content(value.strip)
    end
  end
end

When(/I (?:update|attempt to update) my profile with:/) do |table|
  attributes = table.rows_hash.transform_values(&:strip)
  visit edit_profile_path
  @previous_profile_snapshot = @user.attributes.slice(*attributes.keys).transform_values(&:to_s)
  attributes.each do |field, value|
    field_name = field.humanize
    # Handle dropdown fields (sleep_schedule, pets, housing_status)
    if ['sleep_schedule', 'pets', 'housing_status'].include?(field.downcase)
      select value, from: field_name
    else
      fill_in field_name, with: value
    end
  end
  click_button 'Save Profile'
  @last_submitted_profile = attributes
end

Then('my profile should be saved with:') do |table|
  expected = table.rows_hash.transform_values(&:strip)
  user = @user.reload
  expected.each do |field, value|
    expect(user.send(field).to_s).to eq(value)
  end
end

Then('I should see a profile update confirmation {string}') do |message|
  expect(page).to have_content(message)
end

Then('the profile should not be saved') do
  expected = @previous_profile_snapshot || {}
  current = @user.reload.attributes.slice(*expected.keys).transform_values { |v| v.to_s }
  expect(current).to eq(expected)
end

Then('I should see a profile validation error {string}') do |message|
  expect(page).to have_content(message)
end

Given('I have uploaded a profile picture') do
  visit edit_profile_path
  attach_file 'Avatar', Rails.root.join('features', 'screenshots', 'create_listing_1.jpg')
  click_button 'Save Profile'
  @user.reload
end

When('I remove my profile picture') do
  visit edit_profile_path
  click_button 'Remove Profile Picture'
end

Then('I should see a profile picture placeholder') do
  expect(page).to have_css('[data-testid="profile-picture-placeholder"]')
end

Then('my profile should not have a profile picture') do
  expect(@user.reload.avatar).to be_nil
end
