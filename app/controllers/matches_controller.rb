class MatchesController < ApplicationController
  before_action :require_login, only: [:index, :show, :generate, :liked_by_matches]

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
    # Get listings liked by this matched user
    @liked_listings = @matched_user.liked_listings.includes(:listing).order(created_at: :desc).limit(5)
  end

  def liked_by_matches
    # Get all users that the current user is matched with
    matched_user_ids = Match.where(user_id: current_user.id).pluck(:matched_user_id)
    
    # Get all listings liked by those matched users
    @liked_listings = LikedListing.where(user_id: matched_user_ids)
                                  .includes(:listing, :user)
                                  .order(created_at: :desc)
                                  .page(params[:page]).per(12)
    
    # Track which listings the current user has also liked
    @current_user_liked_ids = current_user.liked_listings.pluck(:listing_id)
  end

end

