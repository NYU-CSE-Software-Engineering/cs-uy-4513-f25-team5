Given('I am logged in as a Community Verifier') do
  @current_user = User.create!(
    email: 'verifier@example.com',
    password: 'password123'
  )
  # Set session for Capybara
  page.driver.post '/auth/login', { email: @current_user.email, password: 'password123' } rescue nil
end

Given('the following listings exist:') do |table|
  table.hashes.each do |row|
    Listing.create!(
      title: row['title'],
      owner_email: row['owner_email'],
      status: row['status'],
      verification_requested: row['verification_requested'] == 'true',
      price: 100,
      city: 'New York'
    )
  end
end

Given('a listing has requested verification') do
  @listing = Listing.find_by(verification_requested: true)
  expect(@listing).not_to be_nil
end

When('I navigate to the verification requests page') do
  visit '/verification_requests'
end

When('I open the {string} listing details') do |title|
  click_link title
end

When('I mark the listing as verified') do
  click_button 'Mark as Verified'
end

Then('I should see the listing marked as {string}') do |status|
  expect(page).to have_content(status)
end

Then('the member should see a {string} badge on the listing page') do |badge_text|
  @listing.reload
  visit "/listings/#{@listing.id}"
  expect(page).to have_content(badge_text)
end

Given('a listing is marked as verified') do
  @verified_listing = Listing.create!(
    title: 'Verified Test Listing',
    owner_email: 'test@example.com',
    status: 'Verified',
    verified: true,
    price: 100,
    city: 'NYC'
  )
end

When('a member views the listing') do
  visit "/listings/#{@verified_listing.id}"
end

Then('they should see a {string} badge') do |badge_text|
  expect(page).to have_content(badge_text)
end

When('a member views an unverified listing') do
  @unverified_listing = Listing.create!(
    title: 'Unverified Test Listing',
    owner_email: 'test2@example.com',
    status: 'pending',
    verified: false,
    price: 100,
    city: 'NYC'
  )
  visit "/listings/#{@unverified_listing.id}"
end

Then('they should not see a {string} badge') do |badge_text|
  expect(page).not_to have_content(badge_text)
end
