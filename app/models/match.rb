class Match < ApplicationRecord
  belongs_to :user
  belongs_to :matched_user, class_name: 'User'

  validates :user_id, presence: true
  validates :matched_user_id, presence: true
  validates :compatibility_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :user_cannot_match_themselves

  scope :potential_for, ->(user) { where(user_id: user.id) }

  before_validation :calculate_compatibility_score, if: -> { compatibility_score.nil? }

  def self.calculate_compatibility_score(user1, user2)
    score = 40.0 # Base score

    # Budget compatibility (25% weight)
    if user1.budget.present? && user2.budget.present?
      budget_diff = (user1.budget - user2.budget).abs
      budget_avg = (user1.budget + user2.budget) / 2.0
      if budget_avg > 0
        budget_similarity = 1.0 - [budget_diff / budget_avg, 1.0].min
        score += budget_similarity * 25
      end
    end

    # Location compatibility (15% weight)
    if user1.preferred_location.present? && user2.preferred_location.present?
      if user1.preferred_location.downcase == user2.preferred_location.downcase
        score += 15
      end
    end

    # Sleep schedule compatibility (15% weight)
    if user1.sleep_schedule.present? && user2.sleep_schedule.present?
      if user1.sleep_schedule.downcase == user2.sleep_schedule.downcase
        score += 15
      end
    end

    # Pets compatibility (10% weight)
    if user1.pets.present? && user2.pets.present?
      if user1.pets.downcase == user2.pets.downcase
        score += 10
      end
    end

    # Common liked listings compatibility (15% weight)
    user1_liked = user1.liked_listings.pluck(:listing_id)
    user2_liked = user2.liked_listings.pluck(:listing_id)
    if user1_liked.any? && user2_liked.any?
      common_listings = (user1_liked & user2_liked).size
      total_unique_listings = (user1_liked | user2_liked).size
      if total_unique_listings > 0
        listing_similarity = common_listings.to_f / total_unique_listings
        score += listing_similarity * 15
      end
    end

    # Cap score at 100
    [score.round(2), 100.0].min
  end

  private

  def calculate_compatibility_score
    return unless user.present? && matched_user.present?
    
    self.compatibility_score = Match.calculate_compatibility_score(user, matched_user)
  end

  def user_cannot_match_themselves
    if user_id == matched_user_id
      errors.add(:matched_user_id, "can't be the same as user")
    end
  end
end

