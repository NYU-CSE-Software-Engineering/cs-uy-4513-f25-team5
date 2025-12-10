# MatchingService
# Generates potential matches for users based on compatibility scores
# 
# Usage:
#   MatchingService.generate_matches_for(user)
#   MatchingService.generate_all_matches
class MatchingService
  MINIMUM_COMPATIBILITY_SCORE = 50.0

  # Generate matches for a specific user
  # Finds all other users and creates Match records for compatible ones
  def self.generate_matches_for(user)
    return unless user.present?

    matches_created = 0
    
    # Find all other users (exclude current user)
    other_users = User.where.not(id: user.id)
    
    other_users.find_each do |other_user|
      # Skip if match already exists
      next if Match.exists?(user_id: user.id, matched_user_id: other_user.id)
      
      # Calculate compatibility score
      score = Match.calculate_compatibility_score(user, other_user)
      
      # Only create match if score meets minimum threshold
      if score >= MINIMUM_COMPATIBILITY_SCORE
        begin
          Match.create!(
            user: user,
            matched_user: other_user,
            compatibility_score: score
          )
          matches_created += 1
        rescue ActiveRecord::RecordInvalid => e
          # Skip if validation fails (e.g., duplicate match somehow created)
          next
        end
      end
    end
    
    matches_created
  end

  # Generate matches for all users in the system
  # Useful for initial setup or periodic batch processing
  def self.generate_all_matches
    total_matches = 0
    
    User.find_each do |user|
      matches_created = generate_matches_for(user)
      total_matches += matches_created if matches_created
    end
    
    total_matches
  end

  # Regenerate matches for a user (delete old ones and create new)
  # Useful when user updates their profile
  def self.regenerate_matches_for(user)
    return unless user.present?
    
    # Delete existing matches for this user (both directions)
    Match.where(user_id: user.id).destroy_all
    Match.where(matched_user_id: user.id).destroy_all
    
    # Regenerate matches for this user
    generate_matches_for(user)
    
    # Regenerate matches for all other users who might match with this user
    User.where.not(id: user.id).find_each do |other_user|
      # Recalculate and update/create match if it meets threshold
      score = Match.calculate_compatibility_score(other_user, user)
      
      if score >= MINIMUM_COMPATIBILITY_SCORE
        Match.find_or_initialize_by(user_id: other_user.id, matched_user_id: user.id).tap do |match|
          match.compatibility_score = score
          match.save
        end
      end
    end
  end
end

