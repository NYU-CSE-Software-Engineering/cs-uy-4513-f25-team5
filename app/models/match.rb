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
      if locations_match?(user1.preferred_location, user2.preferred_location)
        score += 15
      end
    end

    # Sleep schedule compatibility (15% weight)
    if user1.sleep_schedule.present? && user2.sleep_schedule.present?
      if user1.sleep_schedule.downcase.strip == user2.sleep_schedule.downcase.strip
        score += 15
      end
    end

    # Pets compatibility (10% weight)
    if user1.pets.present? && user2.pets.present?
      if pets_compatible?(user1.pets, user2.pets)
        score += 10
      end
    end

    # Housing status compatibility (10% weight)
    if user1.housing_status.present? && user2.housing_status.present?
      housing_score = housing_status_compatibility(user1.housing_status, user2.housing_status)
      score += housing_score
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

  # Helper method to calculate housing status compatibility
  # Returns a score from 0 to 10 based on compatibility
  def self.housing_status_compatibility(status1, status2)
    return 0 if status1.blank? || status2.blank?
    
    norm1 = status1.to_s.strip
    norm2 = status2.to_s.strip
    
    # Flexible matches with everything
    return 10 if norm1 == 'Flexible' || norm2 == 'Flexible'
    
    # Perfect complementary matches (10 points)
    # People looking for rooms match with people who have rooms
    if (norm1 == 'Looking for Room' && (norm2 == 'Have Room Available' || norm2 == 'Looking for Roommate'))
      return 10
    end
    if (norm2 == 'Looking for Room' && (norm1 == 'Have Room Available' || norm1 == 'Looking for Roommate'))
      return 10
    end
    
    # Moderate match (5 points)
    # Two people looking for rooms might team up to find a place together
    if norm1 == 'Looking for Room' && norm2 == 'Looking for Room'
      return 5
    end
    
    # Two people looking for roommates might have space for each other
    if norm1 == 'Looking for Roommate' && norm2 == 'Looking for Roommate'
      return 5
    end
    
    # No compatibility
    0
  end
end

