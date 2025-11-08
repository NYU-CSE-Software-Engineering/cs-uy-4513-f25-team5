Given('the test database is clean') do
  DatabaseCleaner.clean_with(:truncation)
end

Given('I am a signed-in user') do
  @current_user ||= User.create!(email: 'test@example.com', password: 'password123')
  @user = @current_user
end
