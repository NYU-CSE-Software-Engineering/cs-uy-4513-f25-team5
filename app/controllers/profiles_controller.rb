require 'base64'

class ProfilesController < ApplicationController
  before_action :require_login
  before_action :set_user

  def show; end

  def edit; end

  def update
    return handle_avatar_removal if removing_avatar?

    uploaded_avatar = avatar_upload
    profile_was_updated = false

    if @user.update(user_params)
      attach_avatar(uploaded_avatar) if uploaded_avatar
      profile_was_updated = true
      
      # Auto-regenerate matches when profile is updated
      # Only if key matching fields were changed
      if profile_fields_changed_for_matching?
        MatchingService.regenerate_matches_for(@user)
      end
      
      redirect_to profile_path, notice: 'Profile updated successfully. Your matches have been refreshed!'
    else
      flash.now[:alert] = 'Display errors before continuing.'
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :display_name,
      :bio,
      :budget,
      :preferred_location,
      :sleep_schedule,
      :pets,
      :housing_status,
      :contact_visibility
    )
  end

  def avatar_upload
    file = params.dig(:user, :avatar)
    return nil unless file.respond_to?(:size) && file.size.positive?

    file
  end

  def attach_avatar(file)
    @user.avatar&.destroy
    encoded = Base64.strict_encode64(file.read)
    file.rewind if file.respond_to?(:rewind)
    @user.create_avatar!(image_base64: encoded, filename: file.original_filename)
  end

  def removing_avatar?
    params[:remove_avatar].present?
  end

  def handle_avatar_removal
    @user.avatar&.destroy
    redirect_to edit_profile_path, notice: 'Profile picture removed.'
  end

  def profile_fields_changed_for_matching?
    # Check if any fields that affect matching were changed
    @user.previous_changes.key?('budget') ||
    @user.previous_changes.key?('preferred_location') ||
    @user.previous_changes.key?('sleep_schedule') ||
    @user.previous_changes.key?('pets') ||
    @user.previous_changes.key?('housing_status')
  end
end
