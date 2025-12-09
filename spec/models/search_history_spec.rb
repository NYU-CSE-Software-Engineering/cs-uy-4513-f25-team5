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

    it 'is valid with user and no search parameters' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      history = SearchHistory.new(user: user)
      expect(history).to be_valid
    end
  end

  describe 'scopes' do
    it 'returns histories in descending order by created_at' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      old_history = SearchHistory.create!(user: user, city: 'Boston', created_at: 1.day.ago)
      new_history = SearchHistory.create!(user: user, city: 'NYC', created_at: Time.current)

      expect(SearchHistory.recent.first).to eq new_history
    end
  end

  describe '#to_params' do
    it 'returns search parameters as a hash' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      history = SearchHistory.create!(
        user: user,
        city: 'New York',
        min_price: 1000,
        max_price: 2000,
        keywords: 'furnished'
      )

      expect(history.to_params).to eq({
        city: 'New York',
        min_price: 1000,
        max_price: 2000,
        keywords: 'furnished'
      })
    end
  end
end
