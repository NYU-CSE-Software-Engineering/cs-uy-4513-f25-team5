class User < ApplicationRecord
  has_many :listings, dependent: :destroy
  has_one :avatar, dependent: :destroy

  ROLES = %w[admin member].freeze

  before_validation :set_default_role
  validates :role, inclusion: { in: ROLES }

  validates :email, presence: true
  validates :display_name, presence: true, if: :profile_display_name_required?
  validates :budget,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  alias_attribute :name, :display_name

  def admin?
    role == 'admin'
  end

  private

  def profile_display_name_required?
    display_name.present? || will_save_change_to_display_name?
  end

  def set_default_role
    self.role ||= 'member'
  end
end
