class VerificationRequestsController < ApplicationController
  def index
    @listings = Listing.pending_verification.order(:created_at)
  end

  def verify
    listing = Listing.find(params[:id])
    listing.mark_as_verified!
    redirect_to verification_requests_path, notice: "Listing verified!"
  end
end
