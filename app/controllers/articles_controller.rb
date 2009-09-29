class ArticlesController < ApplicationController
  DEFAULT_PER_PAGE = 30
  
  before_filter :login_required, :except => [:index, :show, :feed, :rss]  
  
  # extend ActionView::Helpers::SanitizeHelper::ClassMethods
  # include ForRSS
  
  def index
    @articles = Article.paginate :page => params['page'], 
      :per_page => params[:limit] || DEFAULT_PER_PAGE, :order => 'updated_at DESC'
    
    respond_to do |f|
      f.html
      f.atom
    end
  end
  
  def rss
    redirect_to :action => 'feed'
  end
  
  def feed
    @articles = Article.paginate :page => params['page'], 
      :per_page => params[:limit] || DEFAULT_PER_PAGE, :order => 'updated_at DESC'
      
    respond_to do |f|
      f.atom { render :action => 'index'}
    end
  end
  
  def new
    @article = Article.new
    [:subject, :body, :url].each do |name|
      @article[name] = params[name].to_s.strip
    end
  end
  
  def create
    @article = current_user.articles.build params[:article]
    respond_to do |format|
      if @article.save
        flash[:notice] = '登録しました'
        format.html { redirect_to(@article) }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  def update
    if params[:id].blank?
      # @article = Article.new :modified_at => Time.now
      status = "posted"
    else
      status = "updated"
      @article = Article.find(params[:id])
    end
    @before_article = @article.dup
    @article.attributes = params[:article]
    @article.user ||= current_user
    Article.transaction {
      unless @article.save
        render :action => "edit"
        return
      end
    }
    # Mailman.deliver_article_update(self, Time.now, :article => {:before => @before_article, :after => @article})
    flash[:notice] = "#{status}"
    flash[:notice_duration] = 0.8
    redirect_to :action => "index"
  end
  
  def show
    @article = Article.find params[:id]
    if current_user
      count = @article.article_view_logs.count :all, 
        :conditions => ['user_id = ? and created_at >= ?', current_user.id, 8.hours.ago]
      if count
        @article.article_view_logs.create :user => current_user
      end
    end
  end
  
  def _show
    @article = Article.get params[:id], current_user
    
    last = viewed_timestamps[params[:id]]
    if last.nil? || Time.now > 1.day.since(last)
      viewed_timestamps[params[:id]] = Time.now
      if logged_in? && (@article.user.id != current_user.id || ENV["RAILS_ENV"] == "development")
        # article.user.user_info.karma += 1
        # article.user.user_info.save!
      end
    end
  end
  
  def show_remote
    show
    render(:update){|page|
      page.replace_html "article_#{@article.id}", render(:partial => "content")
    }
  end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  def bookmark
    @articles = Article.paginate :page => params['page'], 
      :conditions => "url is not null",
      :per_page => params[:limit] || DEFAULT_PER_PAGE, :order => 'url_access_at DESC'
    render :action => "index"
  end
  
  def tagged
    @tag = params[:tag]
    @articles = @queries.empty? ?
      Article.paginate(page_opts) :
      Article.paged_find_tagged_with(@tag.split(/[\s　]/), page_opts)
    render :action => 'index'
  end
  
  def most_viewed
    case params[:period]
    when "week"
      @page_title = "in a week"
      before_time = 1.week.ago
    when "month"
      @page_title = "in a month"
      before_time = 1.month.ago
    when "all"
      @page_title = "in the whole"
      before_time = 1.years.ago
    else
      @page_title = "today"
      before_time = Time.now.beginning_of_day
    end
    
    @articles = Article.most_viewed_with_paginate before_time, params[:page], DEFAULT_PER_PAGE
    render :action => 'index'
  end
  
  private
  def page_opts
    {
      :page => params['page'], 
      :per_page => params[:limit] || DEFAULT_PER_PAGE, 
      :order => 'url_access_at DESC'
    }
  end  
  def viewed_timestamps
    session[:article_viewed_timestamp] ||= {}
  end
  
  def tags_string_to_tag_names(tags_string)
    tags_string.to_s.split(TAG_SEPARATOR).find_all{|tag|!tag.empty?}
  end
end
