# Step definitions for search history feature

When('I am on the search history page') do
  visit search_history_path
end

When('I click on {string}') do |link_text|
  click_on link_text
end

Then('I should be on the search listings page') do
  expect(current_path).to eq(search_listings_path)
end
