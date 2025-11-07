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

    it 'rejects invalid status values' do
      listing = Listing.new(
        title: 'Test',
        price: 100,
        city: 'NYC',
        owner_email: 'test@example.com',
        status: 'invalid_status'
      )
      expect(listing).not_to be_valid
      expect(listing.errors[:status]).to include("is not included in the list")
    end
  end

  describe '#mark_as_verified!' do
    it 'changes the listing status to Verified' do
      listing = Listing.create!(
        title: 'Test Listing',
        price: 100,
        city: 'NYC',
        owner_email: 'owner@example.com',
        status: 'pending',
        verification_requested: true
      )

      listing.mark_as_verified!

      expect(listing.status).to eq('Verified')
      expect(listing.verified).to eq(true)
    end

    it 'persists the verification to the database' do
      listing = Listing.create!(
        title: 'Test Listing',
        price: 100,
        city: 'NYC',
        owner_email: 'owner@example.com',
        status: 'pending'
      )

      listing.mark_as_verified!
      listing.reload

      expect(listing.status).to eq('Verified')
      expect(listing.verified).to eq(true)
    end
  end

  describe '.pending_verification' do
    before do
      @listing1 = Listing.create!(
        title: 'Needs Verification',
        price: 100,
        city: 'NYC',
        owner_email: 'alice@example.com',
        status: 'pending',
        verification_requested: true
      )
      @listing2 = Listing.create!(
        title: 'No Verification',
        price: 100,
        city: 'NYC',
        owner_email: 'bob@example.com',
        status: 'published',
        verification_requested: false
      )
      @listing3 = Listing.create!(
        title: 'Another Verification',
        price: 100,
        city: 'NYC',
        owner_email: 'charlie@example.com',
        status: 'pending',
        verification_requested: true
      )
    end

    it 'returns only listings with verification_requested true' do
      pending_listings = Listing.pending_verification
      expect(pending_listings).to include(@listing1, @listing3)
      expect(pending_listings).not_to include(@listing2)
    end
  end
end