Given("I have a listing titled {string}") do |title|
  @user ||= User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
  @listing ||= Listing.create!(
    title: title,
    description: 'Original description',
    price: 800,
    city: 'NYC',
    status: Listing::STATUS_PENDING,
    owner_email: @user.email,
    user: @user
  )
end

Given("another user has a listing titled {string}") do |title|
  @other_user ||= User.create!(email: "other@example.com", password: "password123", password_confirmation: "password123")
  @other_listing ||= Listing.create!(
    title: title,
    description: "Other listing",
    price: 1500,
    city: "Boston",
    status: Listing::STATUS_PENDING,
    owner_email: @other_user.email,
    user: @other_user
  )
end

# Edit Listing Steps

When("I visit the edit page for {string}") do |title|
  listing = Listing.find_by(title: title)
  visit edit_listing_path(listing)
end

Then("I should see the message {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should see {string} on the listing page") do |content|
  expect(page).to have_content(content)
end

Then("I should see {string} on the listings page") do |content|
  visit listings_path
  expect(page).to have_content(content)
end

Then("I should see an authorization error message") do
  has_error = page.has_content?("You are not authorized") || 
              page.has_content?("Access denied") ||
              page.has_content?("error")
  expect(has_error).to be true
end

Then("I should see a validation error message") do
  expect(page).to have_content("Invalid listing contents")
end

Then("the listing details should remain unchanged") do
  @listing.reload
  expect(@listing.title).to eq("Cozy Studio Apartment")
  expect(@listing.price).to eq(800)
end

# Delete Listing Steps

When("I click {string} for {string}") do |action, title|
  listing = Listing.find_by(title: title)
  visit listings_path
  # Find the listing and click delete
  within("tr:has-text('#{title}')") do
    click_link action
  end
rescue
  # Alternative: visit listing show page and delete from there
  visit listing_path(listing)
  click_button action
end

Then("I should not see {string} on my listings page") do |title|
  visit listings_path
  expect(page).not_to have_content(title)
end

# Access Control Steps

Then("I should see an error message") do
  expect(page).to have_content("You are not authorized to edit this listing.")
end
