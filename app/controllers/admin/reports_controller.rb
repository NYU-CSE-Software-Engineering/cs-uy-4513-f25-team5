class Admin::ReportsController < ApplicationController
  # before_action :require_admin

  def index
    @reports = Report.all
  end

  # def require_admin
  #   unless current_user.admin?
  #     redirect_to root_path, alert: 'You are not authorized to access this page'
  #   end
  # end
end