class SearchHistory < ApplicationRecord
  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }

  def to_params
    {
      city: city,
      min_price: min_price,
      max_price: max_price,
      keywords: keywords
    }.compact_blank
  end
end
