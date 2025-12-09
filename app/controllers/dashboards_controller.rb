class DashboardsController < ApplicationController
  before_action :require_login

  def show
    # Get match statistics for the current user
    @matches = Match.potential_for(current_user).includes(:matched_user)
    @matches_count = @matches.count
    @top_matches = @matches.order(compatibility_score: :desc).limit(3)
    
    # Get conversation count
    @conversations_count = current_user.conversations_as_participant_one.count + 
                          current_user.conversations_as_participant_two.count
    
    # Check if profile is complete enough for matching
    @profile_complete = current_user.budget.present? && 
                       current_user.preferred_location.present? &&
                       current_user.sleep_schedule.present?
  end
end

