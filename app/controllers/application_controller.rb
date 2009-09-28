# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

APPLICATION_TITLE   = "ノウハウの杜"
URL_TRUNCATE_LENGTH = 64
TAG_SEPARATOR       = %r/[　\s,;]+/

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem
  
  def my_category
    self.class.global_navi_category || self.controller_name
  end
  class << self
    attr_accessor :global_navi_category
    def set_global_navi_category(global_navi_category)
      @global_navi_category = global_navi_category.to_s
    end
  end
  
  layout proc{ |r| r.request.request_uri.index(/admin/) ? "application" : "application" }
end
