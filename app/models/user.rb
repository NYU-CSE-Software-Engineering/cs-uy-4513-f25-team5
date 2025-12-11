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
  before_validation :set_default_display_name, on: :create
  validates :role, inclusion: { in: ROLES }

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, on: :create
  validate :password_strength, if: -> { password.present? }
  validates :display_name, presence: true, if: :profile_display_name_required?
  validates :budget,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  alias_attribute :name, :display_name

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

  def set_default_display_name
    return if display_name.present?

    if email.present? && email.include?('@')
      self.display_name = email.to_s.split('@').first.presence || 'User'
    else
      self.display_name = 'User'
    end
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
end