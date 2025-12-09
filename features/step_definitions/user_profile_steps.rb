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
      # Map test values to expected normalized values
      expected_value = case field.downcase
      when 'sleep_schedule'
        case value.downcase
        when /early|riser/
          /Early Bird/i
        when /night|owl/
          /Night Owl/i
        when /regular|normal/
          /Regular Schedule/i
        when /flexible/
          /Flexible/i
        else
          /#{Regexp.escape(value.strip)}/i
        end
      when 'pets'
        case value.downcase
        when /no|none|don't|dont/
          /None/i
        when /cat|cats/
          /Cat/i
        when /dog|dogs/
          /Dog/i
        when /friendly|open|ok/
          /Pet Friendly/i
        else
          /#{Regexp.escape(value.strip)}/i
        end
      when 'housing_status'
        case value.downcase
        when /looking for room|need room/
          /Looking for Room/i
        when /looking for roommate|need roommate/
          /Looking for Roommate/i
        when /have room|room available/
          /Have Room Available/i
        when /flexible|matched but flexible/
          /Flexible/i
        else
          /#{Regexp.escape(value.strip)}/i
        end
      when 'preferred_location'
        /#{Regexp.escape(value.strip)}/i
      else
        /#{Regexp.escape(value.strip)}/i
      end
      expect(page).to have_content(expected_value)
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
      # Map test values to dropdown options
      mapped_value = case field.downcase
      when 'sleep_schedule'
        case value.downcase
        when /early|riser/
          'Early Bird'
        when /night|owl/
          'Night Owl'
        when /regular|normal/
          'Regular Schedule'
        when /flexible/
          'Flexible'
        else
          value  # Use as-is if it matches an option
        end
      when 'pets'
        case value.downcase
        when /no|none|don't|dont/
          'None'
        when /cat|cats/
          'Cat'
        when /dog|dogs/
          'Dog'
        when /friendly|open|ok/
          'Pet Friendly'
        when /other/
          'Other'
        else
          value
        end
      when 'housing_status'
        case value.downcase
        when /looking for room|need room|seeking room/
          'Looking for Room'
        when /looking for roommate|need roommate|seeking roommate/
          'Looking for Roommate'
        when /have room|room available|have space/
          'Have Room Available'
        when /flexible|matched but flexible|either/
          'Flexible'
        else
          value
        end
      else
        value
      end
      select mapped_value, from: field_name
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
    actual_value = user.send(field).to_s
    # Handle case-insensitive comparison for fields that get normalized
    if field == 'preferred_location'
      expect(actual_value.downcase).to eq(value.downcase)
    elsif field == 'sleep_schedule'
      # Sleep schedule gets normalized (e.g., "Night owl" -> "Night Owl")
      expect(actual_value.downcase).to eq(value.downcase)
    elsif field == 'pets'
      # Pets field gets normalized (e.g., "Open to cats" -> "Cat", "No pets" -> "None")
      # Map test values to expected normalized values
      expected_normalized = case value.downcase
      when /no|none|don't|dont/
        'None'
      when /cat|cats|open to cats/
        'Cat'
      when /dog|dogs|open to dogs/
        'Dog'
      when /friendly|open|ok/
        'Pet Friendly'
      when /other/
        'Other'
      else
        value
      end
      expect(actual_value).to eq(expected_normalized)
    elsif field == 'housing_status'
      # Housing status gets normalized (e.g., "Matched but flexible" -> "Flexible")
      expected_normalized = case value.downcase
      when /looking for room|need room|seeking room/
        'Looking for Room'
      when /looking for roommate|need roommate|seeking roommate/
        'Looking for Roommate'
      when /have room|room available|have space/
        'Have Room Available'
      when /flexible|matched but flexible|either/
        'Flexible'
      else
        value
      end
      expect(actual_value).to eq(expected_normalized)
    else
      expect(actual_value).to eq(value)
    end
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
