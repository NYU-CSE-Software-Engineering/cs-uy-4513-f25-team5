Given("a user exists with:") do |table|
  attrs = table.rows_hash
  User.create!(email: attrs["email"], password: attrs["password"])
end

When("I visit the login page") do
  visit auth_login_path
end

When("I log in with:") do |table|
  attrs = table.rows_hash
  visit auth_login_path
  fill_in "Email", with: attrs["email"]
  fill_in "Password", with: attrs["password"]
  click_button "Log In"
end
When("I log in via API with:") do |table|
  attrs = table.rows_hash
  page.driver.post(
    "/auth/login",
    { email: attrs["email"], password: attrs["password"] },
    { "Accept" => "application/json" } # THIS tells Rails to respond with JSON
  )
end


When("I log out") do
  visit auth_logout_path
end

When("I log out via API") do
  page.driver.delete("/auth/logout", {}, { "Accept" => "application/json" })
end

Then("the JSON response should have no content") do
  expect(page.status_code).to eq(204)
end
