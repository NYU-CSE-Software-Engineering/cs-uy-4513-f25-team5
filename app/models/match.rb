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
      if locations_match?(user1.preferred_location, user2.preferred_location)
        score += 20
      end
    end

    # Sleep schedule compatibility (20% weight)
    if user1.sleep_schedule.present? && user2.sleep_schedule.present?
      if user1.sleep_schedule.downcase.strip == user2.sleep_schedule.downcase.strip
        score += 20
      end
    end

    # Pets compatibility (10% weight)
    if user1.pets.present? && user2.pets.present?
      if pets_compatible?(user1.pets, user2.pets)
        score += 10
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

  # Helper method to check if locations match (handles variations)
  def self.locations_match?(loc1, loc2)
    return false if loc1.blank? || loc2.blank?
    
    # Normalize locations
    norm1 = loc1.downcase.strip
    norm2 = loc2.downcase.strip
    
    # Exact match
    return true if norm1 == norm2
    
    # Handle common variations
    location_variations = {
      'new york' => ['nyc', 'new york city', 'ny'],
      'manhattan' => ['nyc', 'new york'],
      'brooklyn' => ['bk', 'bklyn'],
      'queens' => [],
      'bronx' => [],
      'staten island' => ['si']
    }
    
    # Check if locations are variations of each other
    location_variations.each do |standard, variations|
      if norm1 == standard.downcase || variations.include?(norm1)
        return true if norm2 == standard.downcase || variations.include?(norm2)
      end
    end
    
    false
  end

  # Helper method to check if pets are compatible
  def self.pets_compatible?(pets1, pets2)
    return false if pets1.blank? || pets2.blank?
    
    norm1 = pets1.downcase.strip
    norm2 = pets2.downcase.strip
    
    # Exact match
    return true if norm1 == norm2
    
    # "Pet Friendly" is compatible with any pet type
    return true if norm1 == 'pet friendly' || norm2 == 'pet friendly'
    
    # "None" only matches with "None" or "Pet Friendly"
    if norm1 == 'none'
      return norm2 == 'none' || norm2 == 'pet friendly'
    end
    if norm2 == 'none'
      return norm1 == 'none' || norm1 == 'pet friendly'
    end
    
    false
  end
end

