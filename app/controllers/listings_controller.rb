class ListingsController < ApplicationController
  before_action :require_login, except: [:index, :show, :search, :explore]
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :remove_image, :set_primary_image, :like, :unlike]
  before_action :authorize_user, only: [:edit, :update, :destroy, :remove_image, :set_primary_image]

  def index
    if params[:id].present?
      @user = User.find_by(id: params[:id])
      
      if @user.nil?
        redirect_to listings_path, alert: 'User not found.'
        return
      end
      
      @listings = @user.listings
      @is_own_listings = current_user == @user
      @user_handle = @user.email.split('@').first
    else
      @listings = Listing.all
      @is_own_listings = false
    end
  end

  def show
    @listing = Listing.find(params[:id])
  end

  def new 
    @listing = Listing.new
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user if current_user
    @listing.owner_email = current_user.email if current_user
    @listing.status = Listing::STATUS_PENDING

    if @listing.save
      # Set first image as primary if images were uploaded
      if @listing.images.attached? && @listing.primary_image_id.blank?
        @listing.update(primary_image_id: @listing.images.first.id.to_s)
      end
      redirect_to @listing, notice: 'Listing was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      # Set first image as primary if images exist but no primary is set
      if @listing.images.attached? && @listing.primary_image_id.blank?
        @listing.update(primary_image_id: @listing.images.first.id.to_s)
      end
      redirect_to @listing, notice: 'Listing was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @listing.destroy
    redirect_to listings_path, notice: 'Listing was successfully deleted.'
  end

  def remove_image
    image = @listing.images.find { |img| img.id.to_s == params[:image_id].to_s }
    
    if image
      was_primary = @listing.primary_image_id == image.id.to_s
      image.purge
      
      # If we removed the primary image, set a new one
      if was_primary && @listing.images.attached?
        @listing.update(primary_image_id: @listing.images.first.id.to_s)
      elsif was_primary
        @listing.update(primary_image_id: nil)
      end
      
      redirect_to edit_listing_path(@listing), notice: 'Image was successfully removed.'
    else
      redirect_to edit_listing_path(@listing), alert: 'Image not found.'
    end
  end

  def set_primary_image
    image = @listing.images.find { |img| img.id.to_s == params[:image_id].to_s }
    
    if image
      @listing.set_primary_image!(image.id)
      redirect_to edit_listing_path(@listing), notice: 'Primary image was updated.'
    else
      redirect_to edit_listing_path(@listing), alert: 'Image not found.'
    end
  end

  def search
    @filters = params.slice(:city, :min_price, :max_price, :keywords).permit!.to_h.symbolize_keys
    @listings = Listing.search(@filters)

    respond_to do |format|
      format.html { render :search }
      format.json { render json: @listings }
    end
  end

  def like
    @listing = Listing.find(params[:id])
    
    if current_user.liked?(@listing)
      redirect_to @listing, alert: 'You have already liked this listing.'
    else
      LikedListing.create!(user: current_user, listing: @listing)
      redirect_to @listing, notice: 'Listing liked successfully.'
    end
  end

  def unlike
    @listing = Listing.find(params[:id])
    liked_listing = LikedListing.find_by(user: current_user, listing: @listing)
    
    if liked_listing
      liked_listing.destroy
      redirect_to @listing, notice: 'Listing unliked successfully.'
    else
      redirect_to @listing, alert: 'You have not liked this listing.'
    end
  end

  def explore
    @listings = Listing.where(status: [Listing::STATUS_PUBLISHED, Listing::STATUS_VERIFIED])
                       .order('RANDOM()')
                       .limit(20)
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    permitted = params.require(:listing).permit(:title, :description, :price, :city, :owner_email, images: [])
    # Convert empty price string to nil to trigger proper validation
    permitted[:price] = nil if permitted[:price].to_s.strip.empty?
    permitted
  end

  def authorize_user
    unless @listing.user == current_user
      redirect_to listings_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
