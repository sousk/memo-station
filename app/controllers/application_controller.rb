# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

APPLICATION_TITLE   = "bad-know-how shrine"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem
  # before_filter :update_session
  # def update_session
  #   logger.debug("before_filter: update_session")
  # 
  #   logger.debug("セッション #{session ? "有効" : "無効"}")
  #   if session[:user]
  # 
  #     # user関連のDBの更新を反映させる。
  #     session[:user].reload
  # 
  #     ::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 1.years.from_now)
  #     logger.debug("#{session[:user].loginname} のセッション生存期間を #{::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_expires]} に更新しました in update_session()")
  #   else
  #     logger.debug("session[:user] は設定されていません in update_session()")
  #   end
  #   return true
  # end
  
  def my_category
    self.class.global_navi_category || self.controller_name
  end
  class << self
    attr_accessor :global_navi_category
    def set_global_navi_category(global_navi_category)
      @global_navi_category = global_navi_category.to_s
    end
  end
  

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  layout proc{ |r| r.request.request_uri.index(/admin/) ? "application" : "application" }
end
