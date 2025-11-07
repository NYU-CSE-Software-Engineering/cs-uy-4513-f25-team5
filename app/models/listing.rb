class Listing < ApplicationRecord
  belongs_to :user, optional: true 

  validates :title, :price, :city, :status, presence: true

  validates :price, numericality: { greater_than: 0 }

  def mark_as_verified!
    update!(status: 'Verified', verified: true)
  end
end
