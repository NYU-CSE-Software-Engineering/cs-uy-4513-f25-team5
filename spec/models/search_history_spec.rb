require 'rails_helper'

RSpec.describe SearchHistory, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    it 'is invalid without a user' do
      history = SearchHistory.new(city: 'New York')
      expect(history).not_to be_valid
    end
  end
end
