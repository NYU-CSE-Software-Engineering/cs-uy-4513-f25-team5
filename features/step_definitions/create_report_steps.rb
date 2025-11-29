Given("an admin exists") do
  @admin ||= User.create!(email: "admin@example.com", password: "password", role: "admin")
end

Given("at least one report exists in the system") do
  @existing_report ||= Report.create!(
    reporter: User.create!(email: "reporter@example.com", password: "password"),
    reported_user: User.create!(email: "reporteduser@example.com", password: "password"),
    report_type: "Harassment",
    description: "Existing test report"
  )
end

# Create Report Scenario

Given("I am signed in") do
  @current_user ||= User.create!(email: "user@example.com", password: "password")
  login_as(@current_user, scope: :user)
end

Given("I am viewing another user's profile") do
  @other_user ||= User.create!(email: "other@example.com", password: "password")
  visit user_path(@other_user)
end

When("I press {string}") do |button_text|
  click_button button_text
end

When("I select {string} from the report type list") do |type|
  select type, from: "report_report_type"
end

When("I enter {string} in the description field") do |description|
  fill_in "report_description", with: description
end

When("I submit the report") do
  click_button "Submit Report"
end

Then("I should see a confirmation message") do
  expect(page).to have_content("Your report has been submitted")
end

Then("the report should be saved in the system") do
  expect(Report.last.report_type).not_to be_nil
end

# Missing Information Scenario

When("I submit the report without selecting a type") do
  click_button "Submit Report"
end

Then("I should see an error message") do
  expect(page).to have_content("Report type can't be blank")
end

Then("the report should not be created") do
  expect(Report.count).to eq(1).or eq(0)
end

# Admin Viewing Reports Scenario

Given("I am signed in as an admin") do
  @admin ||= User.create!(email: "admin2@example.com", password: "password", role: "admin")
  login_as(@admin, scope: :user)
end

When("I visit the admin reports page") do
  visit admin_reports_path
end

Then("I should see a list of all submitted reports") do
  expect(page).to have_css(".report-row", minimum: 1)
end

Then("each report should display the reporter, reported user, and report type") do
  Report.all.each do |report|
    expect(page).to have_content(report.reporter.email)
    expect(page).to have_content(report.reported_user.email)
    expect(page).to have_content(report.report_type)
  end
end
