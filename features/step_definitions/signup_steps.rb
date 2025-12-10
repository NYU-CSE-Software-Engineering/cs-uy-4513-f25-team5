When('I visit the signup page') do
  visit auth_register_path
end

When('I sign up with:') do |table|
  data = table.rows_hash.transform_values(&:strip)
  visit auth_register_path
  fill_in 'Email', with: data['email']
  fill_in 'Password', with: data['password']
  fill_in 'Password confirmation', with: data['password_confirmation']
  click_button 'Sign Up'
end

Then('I should be redirected to the dashboard') do
  expect(page.current_path).to eq(dashboard_path)
end


When("I sign up via API with:") do |table|
  attrs = table.rows_hash
  page.driver.post(
    "/auth/register",
    { user: attrs },
    { "Accept" => "application/json" } # THIS is crucial
  )
end


Then("the JSON response should contain:") do |table|
  table.rows_hash.each do |field, value|
    expect(JSON.parse(page.body)["user"][field]).to eq(value)
  end
end
