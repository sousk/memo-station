ActionController::Routing::Routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "articles"

  map.connect "search",        :controller => "articles", :action => "search"
  map.connect "new",           :controller => "articles", :action => "new"
  map.connect "edit/:id",      :controller => "articles", :action => "edit"
  map.connect "show/:id",      :controller => "articles", :action => "show"
  map.connect "list",          :controller => "articles", :action => "list"
  map.connect "rss",           :controller => "articles", :action => "rss"
  map.connect "bookmarklet",   :controller => "articles", :action => "bookmarklet"
  map.connect "report",        :controller => "articles", :action => "report"
  map.connect "export",        :controller => "articles", :action => "export"
  map.connect "bookmark",      :controller => "articles", :action => "bookmark"
  map.connect "recent_viewed", :controller => "articles", :action => "recent_viewed"
  map.connect "most_viewed",   :controller => "articles", :action => "most_viewed"

  map.connect "login",       :controller => "account",  :action => "login"
  map.connect "logout",      :controller => "account",  :action => "logout"
  map.connect "signup",      :controller => "account",  :action => "signup"
  map.connect "home",        :controller => "mypage"
  map.css "css/:action", :controller => "stylesheet"
  map.profile "profile/:loginname", :controller => "user_info",  :action => "profile"
#   map.connect "search/plugin", :connect => "articles", :action => "searchplugin"
  map.connect "#{SEARCH_PLUGIN_NAME}.src",     :controller => "articles", :action => "search_plugin_source"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
