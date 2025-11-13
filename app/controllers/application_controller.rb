class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user =
      if session[:user_id]
        User.find_by(id: session[:user_id])
      else
        user = User.first || bootstrap_demo_user
        session[:user_id] = user.id
        user
      end
  end

  def bootstrap_demo_user
    # TODO: Replace this bootstrap user with real authentication once login is implemented.
    User.create!(email: 'demo@example.com', password: 'password123')
  end
end
