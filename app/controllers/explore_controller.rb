class ExploreController < ApplicationController
  before_action :require_login

  def index
    # Get all published/verified listings, ordered by most recent first
    @listings = Listing.where(status: [Listing::STATUS_PUBLISHED, Listing::STATUS_VERIFIED])
                      .order(created_at: :desc)
                      .page(params[:page]).per(12)
    
    # Track which listings the current user has liked
    @liked_listing_ids = current_user.liked_listings.pluck(:listing_id)
  end
end
