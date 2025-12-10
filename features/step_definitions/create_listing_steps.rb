When(/I (?:create|attempt to create) a listing with:/) do |table|  
  visit new_listing_path
  data = table.rows_hash
  
  fill_in 'Title', with: data['title'] || ''
  fill_in 'Description', with: data['description'] || ''
  
  # For number fields, handle empty values properly
  # When price is empty, ensure the field is truly empty (browsers may convert empty number fields to 0)
  price_value = data['price'].to_s.strip
  if price_value.empty?
    # Clear the field using JavaScript to ensure it's truly empty
    price_field = find_field('Price')
    page.execute_script("arguments[0].value = ''; arguments[0].dispatchEvent(new Event('input', { bubbles: true }));", price_field.native)
  else
    fill_in 'Price', with: price_value
  end
  
  fill_in 'City', with: data['city'] || ''
  click_button 'Create Listing'
end

Then('the listing {string} should exist in the database') do |title|
  listing = Listing.find_by(title: title)
  expect(listing).not_to be_nil
end

Then('the listing should belong to the signed-in user') do
  listing = Listing.last
  expect(listing.user_id).to eq(@user.id)
end

Then('the listing should not be saved') do
  expect(Listing.count).to eq(0)
end

Then('I should see a validation error for {string}') do |field|
  expect(page).to have_content("#{field.capitalize} can't be blank")
end

Then('I should see a validation error {string}') do |message|
  expect(page).to have_content(message)
end

Given('there is a listing titled {string}') do |title|
  @listing ||= Listing.create!(
    title: title,
    description: 'Some description',
    price: 500,
    city: 'Test City',
    user: @user || User.create!(email: 'test2@example.com', password: 'password')
  )
end
