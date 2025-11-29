require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'authentication' do
    it 'stores password securely (has_secure_password expected)' do
      user = User.create(email: 'test@example.com', password: 'password123')
      # When has_secure_password is present, authenticate works; otherwise this will fail
      expect(user.authenticate('password123')).to be_truthy
      expect(user.authenticate('wrong')).to be_falsey
    end
  end

  describe 'password strength validation' do
    it 'rejects passwords that are too short' do
      user = User.new(email: 'short@example.com', password: 'short1', password_confirmation: 'short1')

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('must be at least 10 characters and include both letters and numbers')
    end

    it 'rejects passwords missing numbers' do
      user = User.new(
        email: 'nonumeric@example.com',
        password: 'longpassword',
        password_confirmation: 'longpassword'
      )

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('must be at least 10 characters and include both letters and numbers')
    end

    it 'accepts strong passwords' do
      user = User.new(email: 'strong@example.com', password: 'Strongpass1', password_confirmation: 'Strongpass1')

      expect(user).to be_valid
    end
  end

  describe 'email validation' do
    it 'rejects invalid email formats' do
      user = User.new(email: 'invalid-email', password: 'password123', password_confirmation: 'password123')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end
end
