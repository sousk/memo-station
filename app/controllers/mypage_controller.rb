class MypageController < ApplicationController
  before_filter :login_required

  def index
  end
  
  def recently_viewed
    if false
      ids = session[:view_articles].keys
      Article.with_scope(:find => {:conditions => ["id IN (?)", ids]}) {
        @article_pages = Paginator.new(self, Article.count, params[:limit] || 30, params[:page])
        @articles = Article.find(:all, :order => "updated_at desc", :offset => @article_pages.current.offset, :limit => @article_pages.items_per_page)
      }
      render :action => "list"
    else
      @article_pages = Paginator.new(self, session[:user].recent_viewed_count, params[:limit] || 30, params[:page])
      @articles = session[:user].recent_viewed(:offset => @article_pages.current.offset, :limit => @article_pages.items_per_page)
      render :action => "list"
    end
  end
  
end
