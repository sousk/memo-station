# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

APPLICATION_TITLE   = "ノウハウの杜"
URL_TRUNCATE_LENGTH = 64
TAG_SEPARATOR       = %r/[　\s,;]+/

class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  include AuthenticatedSystem
  before_filter :login_required
  
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
  
  def render_404
    render :file => "#{RAILS_ROOT}/public/404.html", :layout => false, :status => 404
  end
  
  rescue_from(ActiveRecord::RecordNotFound) do |e|
    render :file => "#{Rails.public_path}/404.html", :status => 404
  end
  # def rescue_action_in_public(exception)
  #   case exception
  #   when ::ActiveRecord::RecordNotFound
  #     render :file => "#{Rails.public_path}/404.html", :status => 404
  #   else
  #     render :file => "#{Rails.public_path}/500.html", :status => 500
  #   end
  # end
end
