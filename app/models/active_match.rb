class ActiveMatch < ApplicationRecord
  belongs_to :user_one, class_name: 'User'
  belongs_to :user_two, class_name: 'User'

  validates :status, presence: true
end

