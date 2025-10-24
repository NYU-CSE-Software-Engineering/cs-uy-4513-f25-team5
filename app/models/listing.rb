class Listing < ApplicationRecord
  belongs_to :user

  validates :title, :price, :city, presence: true

  validates :price, numericality: { greater_than: 0 }
end
