class ListingsController < ApplicationController
  before_action :require_login, except: [:index, :show, :search]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

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
    image = @listing.images.attachments.find_by(id: params[:image_id])
    
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
    image = @listing.images.attachments.find_by(id: params[:image_id])
    
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

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :price, :city, :owner_email, images: [])
  end

  def authorize_user
    unless @listing.user == current_user
      redirect_to listings_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
