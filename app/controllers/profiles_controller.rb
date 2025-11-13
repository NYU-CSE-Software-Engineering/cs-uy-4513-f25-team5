require 'base64'

class ProfilesController < ApplicationController
  before_action :ensure_current_user!
  before_action :set_user

  def show; end

  def edit; end

  def update
    return handle_avatar_removal if removing_avatar?

    uploaded_avatar = avatar_upload

    if @user.update(user_params)
      attach_avatar(uploaded_avatar) if uploaded_avatar
      redirect_to profile_path, notice: 'Profile updated successfully'
    else
      flash.now[:alert] = 'Display errors before continuing.'
      render :edit, status: :unprocessable_content
    end
  end

  private

  def ensure_current_user!
    head :unauthorized unless current_user
  end

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
    params.dig(:user, :avatar)
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
end
