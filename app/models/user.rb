class User < ApplicationRecord
  has_many :listings

  validates :email, presence: true

  alias_attribute :name, :display_name
end
