class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy

  validates :email, allow_nil: true
  validates :password, presence: true, on: :create

  alias_attribute :name, :display_name
end
