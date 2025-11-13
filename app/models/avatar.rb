class Avatar < ApplicationRecord
  belongs_to :user

  validates :image_base64, presence: true

  def data_uri
    "data:image/*;base64,#{image_base64}"
  end
end
