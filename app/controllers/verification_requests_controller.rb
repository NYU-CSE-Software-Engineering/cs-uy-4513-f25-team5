class VerificationRequestsController < ApplicationController
  def index
    @listings = Listing.pending_verification.order(:created_at)
  end
end
