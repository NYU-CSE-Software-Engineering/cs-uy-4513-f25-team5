require 'rails_helper'

RSpec.describe Listing, type: :model do
  describe 'database columns' do
    it 'has an owner_email column' do
      listing = Listing.new
      expect(listing).to respond_to(:owner_email)
    end
  end
end