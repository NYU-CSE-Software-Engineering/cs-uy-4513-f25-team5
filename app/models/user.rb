class User < ApplicationRecord
  has_secure_password

  has_many :listings, dependent: :destroy
  has_one :avatar, dependent: :destroy
  has_many :conversations_as_participant_one, class_name: 'Conversation', foreign_key: 'participant_one_id', dependent: :destroy
  has_many :conversations_as_participant_two, class_name: 'Conversation', foreign_key: 'participant_two_id', dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :display_name, presence: true, if: :profile_display_name_required?
  validates :budget,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  alias_attribute :name, :display_name

  private

  def profile_display_name_required?
    display_name.present? || will_save_change_to_display_name?
  end
end