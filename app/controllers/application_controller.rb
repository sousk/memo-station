# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

APPLICATION_TITLE   = "bad-know-how shrine"

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

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
