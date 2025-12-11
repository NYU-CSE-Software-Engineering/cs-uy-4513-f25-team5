class ListingsController < ApplicationController
  before_action :require_login, except: [:index, :show, :search]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]

  def index
    @filters = params.slice(:city, :min_price, :max_price, :keywords).permit!.to_h.symbolize_keys
    
    # Check if this is a "My Listings" page (from user_listings_path)
    if params[:id].present?
      @user = User.find(params[:id])
      @listings = @user.listings
      @is_my_listings = true
    elsif @filters.values.any?(&:present?)
      @listings = Listing.search(@filters)
      @is_my_listings = false
    else
      @listings = Listing.all
      @is_my_listings = false
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
      redirect_to @listing, notice: 'Listing was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: 'Listing was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    redirect_to listings_path, notice: 'Listing was successfully deleted.'
  end

  def search
    @filters = params.slice(:city, :min_price, :max_price, :keywords).permit!.to_h.symbolize_keys
    @listings = Listing.search(@filters)

    respond_to do |format|
      format.html { redirect_to listings_path(params: @filters) }
      format.json { render json: @listings }
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :price, :city, :owner_email)
  end

  def authorize_user
    unless @listing.user == current_user
      redirect_to listings_path, alert: 'You are not authorized to perform this action.'
    end
  end
end
