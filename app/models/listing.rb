class Listing < ApplicationRecord
  belongs_to :user, optional: true

  # Status constants
  STATUS_PENDING = 'pending'.freeze
  STATUS_PUBLISHED = 'published'.freeze
  STATUS_VERIFIED = 'Verified'.freeze

  validates :title, :price, :city, :status, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending published Verified] }

  scope :pending_verification, -> { where(verification_requested: true) }

  def mark_as_verified!
    update!(status: STATUS_VERIFIED, verified: true)
  end
end
