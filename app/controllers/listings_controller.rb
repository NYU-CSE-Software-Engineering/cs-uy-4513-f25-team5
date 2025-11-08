class ListingsController < ApplicationController
  def show
    @listing = Listing.find(params[:id])
  end

  def search
    @filters = params.slice(:city, :min_price, :max_price, :keywords).permit!.to_h.symbolize_keys
    @listings = Listing.search(@filters)

    respond_to do |format|
      format.html { render :search }
      format.json { render json: @listings }
    end
  end
end
