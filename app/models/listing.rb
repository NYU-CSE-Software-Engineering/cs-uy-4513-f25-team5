class Listing < ApplicationRecord
  belongs_to :user, optional: true

  # Status constants
  STATUS_PENDING = 'pending'.freeze
  STATUS_PUBLISHED = 'published'.freeze
  STATUS_VERIFIED = 'Verified'.freeze

  validates :title, :price, :city, :status, :owner_email, presence: true
  validates :price, numericality: { greater_than: 0 }

  def self.search(filters = {})
    scope = all

    city = filters[:city]
    scope = scope.where('LOWER(city) = ?', city.downcase) if city.present?

    min_price = filters[:min_price]
    max_price = filters[:max_price]
    if min_price.present? && max_price.present?
      scope = scope.where(price: min_price..max_price)
    elsif min_price.present?
      scope = scope.where('price >= ?', min_price)
    elsif max_price.present?
      scope = scope.where('price <= ?', max_price)
    end

    keywords = filters[:keywords]
    if keywords.present?
      pattern = "%#{keywords.downcase}%"
      scope = scope.where('LOWER(title) LIKE ? OR LOWER(description) LIKE ?', pattern, pattern)
    end

    scope
  end
end
