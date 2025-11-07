class Listing < ApplicationRecord
  belongs_to :user

  validates :title, :price, :city, presence: true

  validates :price, numericality: { greater_than: 0 }

  def self.search(filters = {})
    scope = all

    city = filters[:city]
    scope = scope.where('LOWER(city) = ?', city.downcase) if city.present?

    scope
  end
end
