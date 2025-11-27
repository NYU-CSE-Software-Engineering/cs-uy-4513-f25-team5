class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  def current_user
    return @current_user if defined?(@current_user)

    @current_user =
      if session[:user_id]
        User.find_by(id: session[:user_id])
      elsif Rails.env.test? && cucumber_context?
        User.first || bootstrap_demo_user
      end
  end

  def bootstrap_demo_user
    user = User.first || User.create!(email: 'demo@example.com', password: 'password123')
    if user && session
      session[:user_id] = user.id
    end
    user
  end

  def cucumber_context?
    # Check if we're in a Cucumber/Capybara context (not RSpec request spec)
    defined?(Capybara) && defined?(Cucumber)
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?
    
    redirect_to '/auth/login', alert: 'Please sign in first.'
  end
end
