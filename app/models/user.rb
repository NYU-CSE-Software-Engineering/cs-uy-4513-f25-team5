class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy
  has_one :avatar, dependent: :destroy
  has_many :conversations_as_participant_one, class_name: 'Conversation', foreign_key: 'participant_one_id', dependent: :destroy
  has_many :conversations_as_participant_two, class_name: 'Conversation', foreign_key: 'participant_two_id', dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :matched_as, class_name: 'Match', foreign_key: 'matched_user_id', dependent: :destroy

  ROLES = %w[admin member].freeze

  before_validation :set_default_role
  validates :role, inclusion: { in: ROLES }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create
  validate :password_strength, if: -> { password.present? }
  validates :display_name, presence: true, if: :profile_display_name_required?
  validates :budget,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  alias_attribute :name, :display_name

  # Standardized values for matching
  SLEEP_SCHEDULE_OPTIONS = [
    'Early Bird',
    'Night Owl',
    'Regular Schedule',
    'Flexible'
  ].freeze

  PETS_OPTIONS = [
    'None',
    'Cat',
    'Dog',
    'Other',
    'Pet Friendly'
  ].freeze

  HOUSING_STATUS_OPTIONS = [
    'Looking for Room',
    'Looking for Roommate',
    'Have Room Available',
    'Flexible'
  ].freeze

  # Normalize values before saving
  before_save :normalize_profile_fields

  def admin?
    role == 'admin'
  end

  def suspend!
    update!(suspended: true)
  end

  def unsuspend!
    update!(suspended: false)
  end

  def active?
    !suspended?
  end

  def destroyable_by?(actor)
    return false if actor == self && admin?

    true
  end

  private

  def profile_display_name_required?
    display_name.present? || will_save_change_to_display_name?
  end

  def set_default_role
    self.role ||= 'member'
  end

  def all_conversations
    Conversation.where("participant_one_id = ? OR participant_two_id = ?", id, id)
  end

  def password_strength
    return if password.blank?

    unless password.length >= 10 && password.match?(/[a-zA-Z]/) && password.match?(/\d/)
      errors.add(:password, 'must be at least 10 characters and include both letters and numbers')
    end
  end

  def normalize_profile_fields
    # Normalize sleep schedule
    if sleep_schedule.present?
      self.sleep_schedule = normalize_sleep_schedule(sleep_schedule)
    end

    # Normalize pets
    if pets.present?
      self.pets = normalize_pets(pets)
    end

    # Normalize housing status
    if housing_status.present?
      self.housing_status = normalize_housing_status(housing_status)
    end

    # Normalize location (remove extra spaces, titleize)
    if preferred_location.present?
      self.preferred_location = preferred_location.strip.titleize
    end
  end

  def normalize_sleep_schedule(value)
    normalized = value.strip.downcase
    
    # Map variations to standard values
    case normalized
    when /early|morning|early bird|earlybird/
      'Early Bird'
    when /night|late|night owl|nightowl|nocturnal/
      'Night Owl'
    when /regular|normal|standard|consistent/
      'Regular Schedule'
    when /flexible|varies|depends/
      'Flexible'
    else
      # If it matches one of our options (case-insensitive), use it
      SLEEP_SCHEDULE_OPTIONS.find { |opt| opt.downcase == normalized } || value.strip.titleize
    end
  end

  def normalize_pets(value)
    normalized = value.strip.downcase
    
    # Map variations to standard values
    case normalized
    when /^no|none|no pets|don't have|dont have|no animals/
      'None'
    when /^cat|cats|feline/
      'Cat'
    when /^dog|dogs|canine|puppy|puppies/
      'Dog'
    when /pet friendly|ok with|okay with|accept/
      'Pet Friendly'
    when /other|different|exotic/
      'Other'
    else
      # If it matches one of our options (case-insensitive), use it
      PETS_OPTIONS.find { |opt| opt.downcase == normalized } || value.strip.titleize
    end
  end

  def normalize_housing_status(value)
    normalized = value.strip.downcase
    
    # Map variations to standard values
    case normalized
    when /looking for room|need room|seeking room|want room|room seeker/
      'Looking for Room'
    when /looking for roommate|need roommate|seeking roommate|want roommate|roommate seeker/
      'Looking for Roommate'
    when /have room|room available|have space|available room|room to rent/
      'Have Room Available'
    when /flexible|either|both|open/
      'Flexible'
    else
      # If it matches one of our options (case-insensitive), use it
      HOUSING_STATUS_OPTIONS.find { |opt| opt.downcase == normalized } || value.strip.titleize
    end
  end
end
