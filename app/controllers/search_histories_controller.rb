class SearchHistoriesController < ApplicationController
  before_action :require_login

  def index
    @search_histories = current_user.search_histories.recent.limit(20)
  end
end
