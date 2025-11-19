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

  describe 'associations' do
    it 'destroys associated listings when the user is destroyed' do
      user = described_class.create!(email: 'owner@example.com', password: 'password123')
      user.listings.create!(
        title: 'Test Listing',
        description: 'Sample',
        price: 500,
        city: 'New York',
        status: Listing::STATUS_PENDING,
        owner_email: user.email
      )

      expect { user.destroy }.to change { Listing.count }.by(-1)
    end

    it 'destroys associated avatar when the user is destroyed' do
      user = described_class.create!(email: 'avatar@example.com', password: 'password123')
      user.create_avatar!(image_base64: 'abc123')

      expect { user.destroy }.to change { Avatar.count }.by(-1)
    end
  end

  describe 'roles' do
    it 'defaults to member' do
      user = described_class.new(email: 'test@example.com', password: 'secret123')
      user.validate
      expect(user.role).to eq('member')
    end

    it 'rejects invalid roles' do
      user = described_class.new(email: 'test@example.com', password: 'secret123', role: 'owner')
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include('is not included in the list')
    end
  end

  describe '#admin?' do
    it 'returns true when role is admin' do
      user = described_class.new(email: 'admin@example.com', password: 'secret', role: 'admin')
    end

    it 'returns false when role is not admin' do
      user = described_class.new(email: 'member@example.com', password: 'secret', role: 'member')
      expect(user.admin?).to be(false)
    end
  end

  describe 'suspension' do
    it 'defaults to active' do
      user = described_class.new(email: 'test@example.com', password: 'secret')

      expect(user).not_to be_suspended
      expect(user).to be_active
    end

    it 'can be suspended and unsuspended' do
      user = described_class.create!(email: 'test@example.com', password: 'secret')

      user.suspend!
      expect(user).to be_suspended
      expect(user).not_to be_active

      user.unsuspend!
      expect(user).not_to be_suspended
      expect(user).to be_active
    end
  end

  describe '#destroyable_by?' do
    let(:admin) do
      described_class.create!(email: 'admin@example.com', password: 'secret', role: 'admin')
    end

    let(:other_admin) do
      described_class.create!(email: 'other@example.com', password: 'secret', role: 'admin')
    end

    it 'returns false when an admin attempts to delete themselves' do
      expect(admin.destroyable_by?(admin)).to be(false)
    end

    it 'returns true when a different admin performs the delete' do
      expect(admin.destroyable_by?(other_admin)).to be(true)
    end
  end
end
