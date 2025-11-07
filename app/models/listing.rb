class Listing < ApplicationRecord
  belongs_to :user, optional: true

  # Status constants
  STATUS_PENDING = 'pending'.freeze
  STATUS_PUBLISHED = 'published'.freeze
  STATUS_VERIFIED = 'Verified'.freeze

  validates :title, :price, :city, :status, :owner_email, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [STATUS_PENDING, STATUS_PUBLISHED, STATUS_VERIFIED] }

  scope :pending_verification, -> { where(verification_requested: true) }

  def mark_as_verified!
    update!(status: STATUS_VERIFIED, verified: true)
  end
end
