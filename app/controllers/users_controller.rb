class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      respond_to do |format|
        format.html { redirect_to dashboard_path, notice: 'Welcome! You have successfully signed up.' }
        format.json { render json: { user: @user.slice(:id, :email, :display_name) }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_content }
      end
    end
  end

  private

  def user_params
    user_params = params.require(:user).permit(:email, :password, :password_confirmation)
    user_params
  end
end

