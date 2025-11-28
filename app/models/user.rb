class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy
  has_one :avatar, dependent: :destroy

  ROLES = %w[admin member].freeze

  before_validation :set_default_role
  validates :role, inclusion: { in: ROLES }

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
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
end
