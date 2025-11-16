class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy

  validates :email, uniqueness: true, allow_nil: true
  validates :password, presence: true, on: :create
  validates :display_name, presence: true, if: :profile_display_name_required?
  validates :budget,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  alias_attribute :name, :display_name

  private

  def profile_display_name_required?
    # Add logic here if needed, or return true to always require it
    # For now, making it optional by returning false
    false
  end
end
