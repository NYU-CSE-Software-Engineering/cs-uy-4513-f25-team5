Given("I have a listing titled {string}") do |title|
  @current_user ||= User.create!(email: 'test@example.com', password: 'password123')
  @listing ||= Listing.create!(
    title: title,
    description: 'Original description',
    price: 800,
    city: 'NYC',
    user: @current_user,
    status: Listing::STATUS_PENDING,
    owner_email: @current_user.email
  )
end

Given("another user has a listing titled {string}") do |title|
  @other_user ||= User.create!(email: 'other@example.com', password: 'password123')
  @other_listing ||= Listing.create!(
    title: title,
    description: "Other listing",
    price: 1500,
    city: "Boston",
    user: @other_user,
    status: Listing::STATUS_PENDING,
    owner_email: @other_user.email
  )
end

# Edit Listing Steps

When("I visit the edit page for {string}") do |title|
  page.driver.post '/auth/login', { email: @current_user.email, password: 'password123' }
  listing = Listing.find_by(title: title)
  visit edit_listing_path(listing)
end

Then("I should see the message {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should see {string} on the listings page") do |content|
  expect(page).to have_content(content)
end

Then("I should see a validation error message") do
  expect(page).to have_content("prohibited this listing from being saved")
end

Then("the listing details should remain unchanged") do
  @listing.reload
  expect(@listing.title).to eq("Cozy Studio Apartment")
  expect(@listing.price).to eq(800)
end

# Delete Listing Steps

When("I click {string} for {string}") do |action, title|
  listing = Listing.find_by(title: title)
  visit listing_path(listing)
  click_button action
end

Then("I should not see {string} on my listings page") do |title|
  visit user_listings_path(@current_user)
  expect(page).not_to have_content(title)
end

# Access Control Steps

Then("I should see an authorization error message") do
  expect(page).to have_content("You are not authorized to perform this action.")
end

When("I visit my listings page") do
  visit user_listings_path(@current_user)
end

Then("I should see {string} on my listings page") do |title|
  visit user_listings_path(@current_user)
  expect(page).to have_content(title)
end
