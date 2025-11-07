class VerificationRequestsController < ApplicationController
  before_action :set_listing, only: [:verify]

  def index
    @listings = Listing.pending_verification.order(:created_at)
  end

  def verify
    @listing.mark_as_verified!
    redirect_to verification_requests_path, notice: "Listing verified!"
  end

  private 

  def set_listing
    @listing = Listing.find(params[:id])
  end
end
