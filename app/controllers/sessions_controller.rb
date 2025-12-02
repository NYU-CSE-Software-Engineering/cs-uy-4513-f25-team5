class SessionsController < ApplicationController
  layout false
  
  def new
  end

  def create
    user = User.find_by(email: params[:email]) if params[:email].present?
    
    if user && user.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to dashboard_path }
        format.json { render json: { user: user }, status: :ok }
      end
    else
      @submitted_email = params[:email]
      flash.now[:alert] = 'Invalid email or password'
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { error: 'Invalid email or password' }, status: :unauthorized }
      end
    end
  end

  def destroy
    reset_session
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Successfully logged out' }
      format.json { head :no_content }
    end
  end
end

