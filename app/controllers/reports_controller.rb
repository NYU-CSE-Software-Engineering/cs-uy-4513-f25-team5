class ReportsController < ApplicationController
  before_action :require_login, only: [:new, :create]

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(report_params.merge(reporter: current_user))
    
    if @report.save
      redirect_to root_path, notice: "Your report has been submitted. Thank you."
    else
      render :new
    end
  end

  private

  def report_params
    params.require(:report).permit(:reported_username, :report_type, :description)
  end
end
