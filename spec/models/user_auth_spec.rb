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
end
