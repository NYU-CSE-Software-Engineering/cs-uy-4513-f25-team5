class MatchesController < ApplicationController
  before_action :require_login, only: [:index, :show, :like, :generate]

  def index
    @matches = Match.potential_for(current_user).includes(:matched_user)
    
    if @matches.empty?
      @no_matches_message = "No matches found"
      @suggestions_message = "Update your profile preferences to find better matches"
    end
  end

  def generate
    matches_created = MatchingService.generate_matches_for(current_user)
    
    if matches_created > 0
      redirect_to matches_path, notice: "Found #{matches_created} new potential match#{matches_created == 1 ? '' : 'es'}!"
    else
      redirect_to matches_path, alert: "No new matches found. Try updating your profile preferences."
    end
  end

  def show
    @match = Match.find(params[:id])
    
    unless @match.user_id == current_user.id
      redirect_to matches_path, alert: "You can only view your own matches"
      return
    end
    
    @matched_user = @match.matched_user
  end

  def like
    @match = Match.find(params[:id])
    
    unless @match.user_id == current_user.id
      redirect_to matches_path, alert: "You can only like your own matches"
      return
    end
    
    # In a real app, you might have a Favorite or LikedMatch model
    # For now, we'll just redirect with a success message
    redirect_to matches_path, notice: "Match saved to favorites!"
  end

  def liked_listings
    # Get all matched users
    matched_user_ids = current_user.matches.pluck(:matched_user_id)
    
    # Get listings liked by matched users with the user who liked them
    @liked_listings = Listing.joins(:liked_listings)
                             .where(liked_listings: { user_id: matched_user_ids })
                             .includes(:liked_listings, :user)
                             .distinct
    
    # Create a hash to store which matched users liked each listing
    @listings_with_likers = {}
    @liked_listings.each do |listing|
      likers = listing.liked_by_users.where(id: matched_user_ids)
      @listings_with_likers[listing.id] = likers
    end
  end

end

