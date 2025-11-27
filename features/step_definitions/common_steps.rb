Given('the test database is clean') do
  DatabaseCleaner.clean_with(:truncation)
end

Given('I am a signed-in user') do
  @current_user ||= User.create!(email: 'test@example.com', password: 'password123')
  @user = @current_user
  # Set session for Capybara - bootstrap fallback will handle if this fails
  visit '/search/listings' rescue nil
  page.driver.post '/auth/login', { email: @current_user.email, password: 'password123' } rescue nil
end
