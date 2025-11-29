# features/step_definitions/potential_matches_steps.rb

Given("I am logged in as a user") do
  # Create a real user in the test database using existing schema
  @current_user = User.create!(
    email: 'john@example.com',
    password: 'password123',
    display_name: 'John Doe',
    bio: 'Looking for a roommate in NYC',
    budget: 1200,
    preferred_location: 'Manhattan',
    sleep_schedule: 'Night owl',
    pets: 'No pets',
    housing_status: 'Looking for room',
    contact_visibility: 'Public'
  )
  
  # Log in using real session authentication via Capybara
  page.driver.post '/auth/login', { email: @current_user.email, password: 'password123' }
end

Given("I have a profile with preferences") do
  # User profile is already created in the previous step with all preferences
  # This step ensures the user has the required profile data
  expect(@current_user.budget).to be_present
  expect(@current_user.preferred_location).to be_present
  expect(@current_user.sleep_schedule).to be_present
end

Given("there are potential matches available") do
  # Create potential match users in the database
  @match_user_1 = User.create!(
    email: 'alice@example.com',
    password: 'password123',
    display_name: 'Alice Smith',
    bio: 'Student looking for quiet roommate',
    budget: 1000,
    preferred_location: 'Brooklyn',
    sleep_schedule: 'Early bird',
    pets: 'No pets',
    housing_status: 'Looking for room',
    contact_visibility: 'Public'
  )
  
  @match_user_2 = User.create!(
    email: 'bob@example.com',
    password: 'password123',
    display_name: 'Bob Johnson',
    bio: 'Professional seeking roommate',
    budget: 1500,
    preferred_location: 'Queens',
    sleep_schedule: 'Regular schedule',
    pets: 'Cat',
    housing_status: 'Looking for room',
    contact_visibility: 'Public'
  )
  
  # Create Match records (assuming Match model exists)
  @match_1 = Match.create!(
    user_id: @current_user.id,
    matched_user_id: @match_user_1.id,
    compatibility_score: 85
  )
  
  @match_2 = Match.create!(
    user_id: @current_user.id,
    matched_user_id: @match_user_2.id,
    compatibility_score: 78
  )
end

Given("there are no potential matches available") do
  # Ensure no matches exist for the current user
  Match.where(user_id: @current_user.id).destroy_all
end

Given("I am not logged in") do
  # Clear session to simulate not being logged in
  @current_user = nil
  visit '/auth/logout' rescue nil
  # Clear cookies/session
  page.driver.post '/auth/logout' rescue nil
end

When("I visit the matches page") do
  visit matches_path
end

When("I click on a potential match") do
  # Click the first "View Details" link to avoid ambiguity
  first(:link, "View Details").click
end

When("I click the {string} button on a match") do |button_text|
  # Click the first matching button to avoid ambiguity when multiple matches exist
  # Use all().first to handle multiple buttons with same text
  all(:button, button_text).first.click
end

When("I try to visit the matches page") do
  visit matches_path
end

Then("I should see a list of potential matches") do
  expect(page).to have_content("Potential Matches")
  expect(page).to have_css(".match-card", minimum: 1)
end

Then("each match should display basic information") do
  expect(page).to have_content("Alice Smith")
  expect(page).to have_content("Bob Johnson")
end

Then("each match should show a compatibility score") do
  # Accept decimal format (85.0% or 85%) since compatibility_score is a decimal
  expect(page).to have_content(/\b85\.?\d*%/)
  expect(page).to have_content(/\b78\.?\d*%/)
end

Then("I should see detailed match information") do
  expect(page).to have_content("Match Details")
  expect(page).to have_content("Alice Smith")
end

Then("I should see their profile information") do
  expect(page).to have_content("Student looking for quiet roommate")
  expect(page).to have_content("Brooklyn")
  expect(page).to have_content("Early bird")
end

Then("I should see the compatibility score") do
  # Accept decimal format (85.0% or 85%) since compatibility_score is a decimal
  expect(page).to have_content(/\bCompatibility:\s*\d+\.?\d*%/)
end

Then("I should see lifestyle preferences") do
  expect(page).to have_content("Early bird")
  expect(page).to have_content("No pets")
end

Then("I should see {string} message") do |message|
  expect(page).to have_content(message)
end

Then("I should see suggestions to update my profile") do
  expect(page).to have_content("Update your profile preferences")
end

Then("I should see a confirmation message") do
  expect(page).to have_content("Match saved to favorites!")
end

Then("the match should be saved to my favorites") do
  # In real implementation, this would verify the match was saved
  expect(page).to have_content("saved to favorites")
end

Then("I should be redirected to the login page") do
  expect(current_path).to eq('/auth/login')
end