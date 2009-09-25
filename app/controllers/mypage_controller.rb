class MypageController < ApplicationController
  before_filter :login_required

  def index
  end
  
  def recently_viewed
    @articles = current_user.paged_recent_viewed params[:page]
    render "articles/index"
  end
end
