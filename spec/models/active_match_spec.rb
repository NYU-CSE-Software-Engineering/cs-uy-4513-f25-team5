require 'rails_helper'

RSpec.describe ActiveMatch, type: :model do
  describe 'validations' do
    it 'is invalid without a status' do
      match = described_class.new(status: nil)

      expect(match).not_to be_valid
      expect(match.errors[:status]).to include("can't be blank")
    end
  end
end

