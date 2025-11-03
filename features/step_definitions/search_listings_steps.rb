# Step definitions for search listings feature

# Background steps - reusing from create_listing_steps.rb
# Note: Given('the test database is clean') is defined in create_listing_steps.rb
# Note: Given('I am a signed-in user') is defined in create_listing_steps.rb
# These steps are reused, so we don't redefine them here to avoid ambiguity

# Navigation steps
Given('I am on the search listings page') do
  visit search_listings_path
end

# Data setup steps
Given('there are listings with the following details:') do |table|
  @user ||= User.find_by(email: 'test@example.com') || User.create!(email: 'test@example.com', password: 'password')
  
  table.hashes.each do |listing_data|
    Listing.create!(
      title: listing_data['title'],
      description: listing_data['description'],
      city: listing_data['city'],
      price: listing_data['price'].to_f,
      user: @user
    )
  end
end

# Form interaction steps - using standard Capybara methods
# When('I fill in {string} with {string}') - already defined in user_login_authentication_steps.rb
# When('I press {string}') - already defined in user_login_authentication_steps.rb

# Assertion steps - checking page content
Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should not see {string}') do |text|
  expect(page).not_to have_content(text)
end

# Path helper methods
def search_listings_path
  '/search/listings'
end

