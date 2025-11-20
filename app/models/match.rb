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
    score = 50.0 # Base score

    # Budget compatibility (30% weight)
    if user1.budget.present? && user2.budget.present?
      budget_diff = (user1.budget - user2.budget).abs
      budget_avg = (user1.budget + user2.budget) / 2.0
      if budget_avg > 0
        budget_similarity = 1.0 - [budget_diff / budget_avg, 1.0].min
        score += budget_similarity * 30
      end
    end

    # Location compatibility (20% weight)
    if user1.preferred_location.present? && user2.preferred_location.present?
      if user1.preferred_location.downcase == user2.preferred_location.downcase
        score += 20
      end
    end

    # Sleep schedule compatibility (20% weight)
    if user1.sleep_schedule.present? && user2.sleep_schedule.present?
      if user1.sleep_schedule.downcase == user2.sleep_schedule.downcase
        score += 20
      end
    end

    # Pets compatibility (10% weight)
    if user1.pets.present? && user2.pets.present?
      if user1.pets.downcase == user2.pets.downcase
        score += 10
      end
    end

    score.round(2)
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

