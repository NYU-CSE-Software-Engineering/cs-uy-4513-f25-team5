class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      session[:user_id] = @user.id
      respond_to do |format|
        format.html { redirect_to '/search/listings', notice: 'Account created successfully!' }
        format.json { render json: { user: @user }, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    params.require(:user, :password).permit(:email)
  end
end

