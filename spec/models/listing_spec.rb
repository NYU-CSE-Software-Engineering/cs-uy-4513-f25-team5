require 'rails_helper'

RSpec.describe Listing, type: :model do
  describe 'database columns' do
    it 'has an owner_email column' do
      listing = Listing.new
      expect(listing).to respond_to(:owner_email)
    end
  end

  describe 'validations' do
    it 'allows valid status values' do
      listing = Listing.new(
        title: 'Test', 
        price: 100, 
        city: 'NYC',
        status: 'pending', 
        owner_email: 'test@example.com'
      )
      expect(listing).to be_valid
    end

    it 'validates status is present' do
      listing = Listing.new(
        title: 'Test', 
        price: 100, 
        city: 'NYC',
        owner_email: 'test@example.com', 
        status: nil
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:status]).to include("can't be blank")
    end
  end
end