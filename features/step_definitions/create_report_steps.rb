# Background Steps

Given("an admin exists") do
  @admin ||= User.find_or_create_by!(email: "admin@example.com") do |user|
    user.password = "password1234"
    user.role = "admin"
  end
end

Given("at least one report exists in the system") do
  reporter ||= User.find_or_create_by!(email: "reporter@example.com") do |user|
    user.password = "password1234"
  end
  
  reported_user ||= User.find_or_create_by!(email: "reporteduser@example.com") do |user|
    user.password = "password1234"
  end
  
  @existing_report ||= Report.create!(
    reporter: reporter,
    reported_user: reported_user,
    reported_username: reported_user.email,
    report_type: "Harassment",
    description: "Existing test report"
  )
end

Given("a reporter user exists") do
  @reporter_user ||= User.find_or_create_by!(email: "cucumberreporter@example.com") do |user|
    user.password = "password1234"
  end
end


# New Reports Page Steps

Given("I am on the \"New Reports\" page") do
  page.driver.post '/auth/login', { email: @reporter_user.email, password: 'password1234' }
  visit new_report_path
end

When("I enter {string} in the username field") do |username|
  fill_in "report[reported_username]", with: username
  @reported_user = User.find_by(email: username)
end

When("I select {string} from the report type list") do |type|
  select type, from: "report[report_type]"
end

When("I enter {string} in the description field") do |description|
  fill_in "report[description]", with: description
end

When("I press the submit button") do
  click_button "Submit Report"
end

When("I submit the report without selecting a type") do
  click_button "Submit Report"
end

# Then Steps

Then("I should see a confirmation") do
  expect(page).to have_content("Your report has been submitted. Thank you.")
end

Then("the report should be saved in the system") do
  expect(Report.last.report_type).not_to be_nil
end

Then("I should see an error message stating report type can't be blank") do
  expect(page).to have_content("Report type can't be blank")  
end

Then("I should see an error message stating the user does not exist") do
  expect(page).to have_content("User does not exist")
end

# Admin Reports Page Steps

Given('I visit the admin reports page as an admin') do
  page.driver.post '/auth/login', { email: @admin.email, password: 'password1234' }
  visit admin_reports_path
end

Then("I should see a list of all submitted reports") do
  expect(page).to have_css(".glass-card", minimum: 1)
  expect(page).to have_content("Reporter:")
  expect(page).to have_content("Reported User:")
end

Then("each report should display the reporter, reported user, and report type") do
  Report.all.each do |report|
    expect(page).to have_content(report.reporter.email)
    expect(page).to have_content(report.reported_user.email)
    expect(page).to have_content(report.report_type)
  end
end
