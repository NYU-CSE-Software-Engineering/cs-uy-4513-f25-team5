require 'rails_helper'

RSpec.describe LikedListing, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:listing) }
  end

  describe 'validations' do
    subject { build(:liked_listing) }
    
    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'prevents duplicate likes for the same user and listing' do
      user = create(:user)
      listing = create(:listing)
      create(:liked_listing, user: user, listing: listing)
      
      duplicate_like = build(:liked_listing, user: user, listing: listing)
      expect(duplicate_like).not_to be_valid
    end
  end

  describe 'user liking behavior' do
    let(:user) { create(:user) }
    let(:listing) { create(:listing) }

    it 'allows a user to like a listing' do
      liked_listing = LikedListing.create(user: user, listing: listing)
      expect(liked_listing).to be_persisted
      expect(user.liked_listings).to include(liked_listing)
    end

    it 'allows different users to like the same listing' do
      user2 = create(:user)
      like1 = create(:liked_listing, user: user, listing: listing)
      like2 = create(:liked_listing, user: user2, listing: listing)
      
      expect(like1).to be_valid
      expect(like2).to be_valid
      expect(listing.liked_by_users).to include(user, user2)
    end
  end
end

