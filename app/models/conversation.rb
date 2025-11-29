class Conversation < ApplicationRecord
  belongs_to :participant_one, class_name: 'User'
  belongs_to :participant_two, class_name: 'User'
  has_many :messages, dependent: :destroy
end
