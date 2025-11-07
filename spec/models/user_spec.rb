require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is invalid without an email' do
      user = described_class.new(email: nil)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end
  end

  describe 'attribute aliases' do
    it 'writes to display_name when name is assigned' do
      user = described_class.new

      expect { user.name = 'Test User' }.to change { user.display_name }.from(nil).to('Test User')
    end
  end
end
