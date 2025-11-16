require 'rails_helper'

RSpec.describe 'Profile', type: :model do
  describe 'validations' do
    it 'allows missing profile attributes when untouched' do
      user = User.new(email: 'profileless@example.com', password: 'password123')

      expect(user).to be_valid
    end

    it 'requires a display name once edited' do
      user = User.create!(email: 'named@example.com', password: 'password123', display_name: 'Original')
      user.display_name = ''

      expect(user).not_to be_valid
      expect(user.errors[:display_name]).to include("can't be blank")
    end

    it 'rejects negative budgets' do
      user = User.new(email: 'budget@example.com', password: 'password123', budget: -10)

      expect(user).not_to be_valid
      expect(user.errors[:budget]).to include('must be greater than or equal to 0')
    end
  end
end
