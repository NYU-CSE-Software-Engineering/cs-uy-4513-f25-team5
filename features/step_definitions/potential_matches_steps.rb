# features/step_definitions/potential_matches_steps.rb

Given("I am logged in as a user") do
  # Mock user login - in real implementation, this would set up authentication
  @current_user = double("User", id: 1, name: "John Doe", email: "john@example.com")
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@current_user)
end

Given("I have a profile with preferences") do
  # Mock user profile - in real implementation, this would create a profile
  @user_profile = double("Profile", 
    budget: 1000, 
    location: "New York", 
    lifestyle_preferences: "Quiet, non-smoker"
  )
  allow(@current_user).to receive(:profile).and_return(@user_profile)
end

Given("there are potential matches available") do
  # Mock potential matches - in real implementation, this would create match records
  @potential_matches = [
    double("Match", 
      id: 1, 
      matched_user: double("User", name: "Alice Smith", age: 25),
      compatibility_score: 85,
      lifestyle_preferences: "Quiet, student"
    ),
    double("Match", 
      id: 2, 
      matched_user: double("User", name: "Bob Johnson", age: 28),
      compatibility_score: 78,
      lifestyle_preferences: "Professional, non-smoker"
    )
  ]
  allow(Match).to receive(:potential_for).with(@current_user).and_return(@potential_matches)
end

Given("there are no potential matches available") do
  # Mock empty matches
  allow(Match).to receive(:potential_for).with(@current_user).and_return([])
end

Given("I am not logged in") do
  # Mock no user logged in
  allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
end

When("I visit the matches page") do
  visit matches_path
end

When("I click on a potential match") do
  click_link "View Details"
end

When("I click the {string} button on a match") do |button_text|
  click_button button_text
end

When("I try to visit the matches page") do
  visit matches_path
end

Then("I should see a list of potential matches") do
  expect(page).to have_content("Potential Matches")
  expect(page).to have_css(".match-card", count: 2)
end

Then("each match should display basic information") do
  expect(page).to have_content("Alice Smith")
  expect(page).to have_content("Bob Johnson")
end

Then("each match should show a compatibility score") do
  expect(page).to have_content("85%")
  expect(page).to have_content("78%")
end

Then("I should see detailed match information") do
  expect(page).to have_content("Match Details")
  expect(page).to have_content("Alice Smith")
end

Then("I should see the compatibility score") do
  expect(page).to have_content("Compatibility: 85%")
end

Then("I should see lifestyle preferences") do
  expect(page).to have_content("Quiet, student")
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
  expect(page).to have_content("Saved")
end

Then("I should be redirected to the login page") do
  expect(current_path).to eq(login_path)
end
