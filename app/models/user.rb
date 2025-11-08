class User < ApplicationRecord
  has_many :listings, dependent: :destroy

  validates :email, presence: true

  alias_attribute :name, :display_name
end
