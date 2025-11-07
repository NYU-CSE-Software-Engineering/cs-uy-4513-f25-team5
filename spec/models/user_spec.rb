require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is invalid without an email' do
      user = User.new(password: 'secret123')

      expect(user).not_to be_valid
      user.validate
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without a password' do
      user = User.new(email: 'test@example.com')

      expect(user).not_to be_valid
      user.validate
      expect(user.errors[:password]).to include("can't be blank")
    end
  end
end
