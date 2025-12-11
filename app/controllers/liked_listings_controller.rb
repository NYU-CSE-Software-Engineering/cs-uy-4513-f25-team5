class LikedListingsController < ApplicationController
  before_action :require_login

  def create
    @listing = Listing.find(params[:id])
    @liked_listing = current_user.liked_listings.build(listing: @listing)

    if @liked_listing.save
      # Regenerate matches for the current user since their liked listings changed
      begin
        MatchingService.regenerate_matches_for(current_user)
      rescue => e
        Rails.logger.error "Error regenerating matches: #{e.message}"
      end
      
      respond_to do |format|
        format.html { redirect_back fallback_location: listing_path(@listing), notice: "Listing saved to favorites!" }
        format.json { render json: { success: true, message: "Listing saved to favorites!" }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: listing_path(@listing), alert: "Unable to save listing." }
        format.json { render json: { success: false, errors: @liked_listing.errors }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @liked_listing = current_user.liked_listings.find_by(listing_id: params[:id])
    
    if @liked_listing
      @listing = @liked_listing.listing
      @liked_listing.destroy
      
      # Regenerate matches for the current user since their liked listings changed
      begin
        MatchingService.regenerate_matches_for(current_user)
      rescue => e
        Rails.logger.error "Error regenerating matches: #{e.message}"
      end
      
      respond_to do |format|
        format.html { redirect_back fallback_location: listing_path(@listing), notice: "Listing removed from favorites." }
        format.json { render json: { success: true, message: "Listing removed from favorites." }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: "Listing not found in favorites." }
        format.json { render json: { success: false, message: "Listing not found in favorites." }, status: :not_found }
      end
    end
  end

  def index
    @liked_listings = current_user.liked_listings.includes(:listing).order(created_at: :desc)
  end
end
