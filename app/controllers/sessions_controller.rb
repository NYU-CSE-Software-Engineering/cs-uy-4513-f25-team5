class SessionsController < ApplicationController
  def new
    # Stub for login page - render plain text for tests
    render plain: 'Login page'
  end

  def create
    user = User.find_by(email: params[:email]) if params[:email].present?
    
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      respond_to do |format|
        format.html { redirect_to '/search/listings', notice: 'Successfully logged in!' }
        format.json { render json: { user: user }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render plain: 'Invalid email or password', status: :unauthorized }
        format.json { render json: { error: 'Invalid email or password' }, status: :unauthorized }
      end
    end
  end

  def destroy
    reset_session
    respond_to do |format|
      format.html { redirect_to '/search/listings', notice: 'Successfully logged out!' }
      format.json { head :no_content }
    end
  end
end

