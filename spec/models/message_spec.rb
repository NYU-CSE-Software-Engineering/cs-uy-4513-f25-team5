require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'validations' do
    it 'requires a body' do
      message = described_class.new(body: nil)

      expect(message).not_to be_valid
      expect(message.errors[:body]).to include("can't be blank")
    end
  end
end

