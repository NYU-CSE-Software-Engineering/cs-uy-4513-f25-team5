class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy]

  def index
    @listings = Listing.all
  end

  def destroy
    @listing.destroy  # This deletes the record from database
    redirect_to listings_path, notice: 'Listing was successfully deleted.'
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

    uploaded_image = image_upload

    if @listing.save
      attach_image(uploaded_image) if uploaded_image
      redirect_to @listing, notice: 'Listing was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @listing = Listing.find(params[:id])

    if params[:listing][:image].present?
      uploaded = params[:listing][:image]
      @listing.filename = uploaded.original_filename
      @listing.image_base64 = Base64.strict_encode64(uploaded.read)
    end

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
      format.html { render :search }
      format.json { render json: @listings }
    end
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def listing_params
    params.require(:listing).permit(:title, :description, :price, :city, :owner_email, :image_base64, :filename)
  end

  def image_upload
    params.dig(:listing, :image)
  end

  def attach_image(file)
    encoded = Base64.strict_encode64(file.read)
    file.rewind if file.respond_to?(:rewind)
    @listing.update(image_base64: encoded, filename: file.original_filename)
  end

  def removing_image?
    params[:remove_image].present?
  end

  def handle_image_removal
    @listing.update(image_base64: nil, filename: nil)
    redirect_to edit_listing_path(@listing), notice: 'Listing image removed.'
  end
end
