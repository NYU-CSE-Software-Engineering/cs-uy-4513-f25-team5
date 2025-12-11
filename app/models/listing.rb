class Listing < ApplicationRecord
  belongs_to :user, optional: true
  has_many_attached :images

  # Status constants
  STATUS_PENDING = 'pending'.freeze
  STATUS_PUBLISHED = 'published'.freeze
  STATUS_VERIFIED = 'verified'.freeze

  # Image constraints
  MAX_IMAGES = 10
  MAX_IMAGE_SIZE = 5.megabytes
  ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'].freeze

  validates :title, :price, :city, :status, :owner_email, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [STATUS_PENDING, STATUS_PUBLISHED, STATUS_VERIFIED] }
  validate :validate_images

  scope :pending_verification, -> { where(verification_requested: true) }

  def mark_as_verified!
    update!(status: STATUS_VERIFIED, verified: true)
  end

  def self.search(filters = {})
    scope = all

    city = filters[:city]
    scope = scope.where("LOWER(city) LIKE ?", "%#{city}%") if city.present?

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

  # Returns the primary image or the first image if no primary is set
  def primary_image
    return nil unless images.attached?
    
    if primary_image_id.present?
      images.find { |img| img.id.to_s == primary_image_id.to_s } || images.first
    else
      images.first
    end
  end

  # Returns images ordered with primary first
  def ordered_images
    return [] unless images.attached?
    
    primary = primary_image
    return images.to_a unless primary
    
    [primary] + images.reject { |img| img.id == primary.id }
  end

  # Set the primary image by attachment id
  def set_primary_image!(attachment_id)
    update!(primary_image_id: attachment_id.to_s)
  end

  # Check if an image is the primary one
  def primary_image?(image)
    return false unless primary_image_id.present?
    image.id.to_s == primary_image_id.to_s
  end

  # How many more images can be added
  def remaining_image_slots
    MAX_IMAGES - (images.attached? ? images.count : 0)
  end

  private
  
  def set_default_status
    self.status ||= STATUS_PENDING
  end

  def validate_images
    return unless images.attached?

    if images.count > MAX_IMAGES
      errors.add(:images, "cannot exceed #{MAX_IMAGES} images")
    end

    images.each do |image|
      unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
        errors.add(:images, "must be JPEG, PNG, WebP, or GIF")
      end

      if image.blob.byte_size > MAX_IMAGE_SIZE
        errors.add(:images, "must be less than #{MAX_IMAGE_SIZE / 1.megabyte}MB each")
      end
    end
  end
end
