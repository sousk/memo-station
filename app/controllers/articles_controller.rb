class ArticlesController < ApplicationController
  DEFAULT_PER_PAGE = 20
  
  before_filter :login_required, :except => [:index, :show, :feed, :rss, :tagged]  
  
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
  
  # def rss
  #   redirect_to :action => 'feed'
  # end
  # 
  def feed
    @articles = Article.find :all, :limit=> params[:limit] || DEFAULT_PER_PAGE
    respond_to do |f|
      f.atom
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
    @article = Article.find(params[:id])
    respond_to do |format|
      if @article.update_attributes params[:article]
        flash[:notice] = '更新しました'
        format.html { redirect_to(article_path(@article)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def show
    @article = Article.find params[:id]
    
    return render_404 unless @article
    
    if logged_in?
      count = @article.article_view_logs.count :all, 
        :conditions => ['user_id = ? and created_at >= ?', current_user.id, 8.hours.ago]
      unless count > 0
        logger.info count
        @article.article_view_logs.create! :user => current_user
      end
    end
  end
  
  # def show_remote
  #   show
  #   render(:update){|page|
  #     page.replace_html "article_#{@article.id}", render(:partial => "content")
  #   }
  # end
  
  def edit
    @article = Article.find(params[:id])
  end
  
  # def bookmark
  #   @articles = Article.paginate :page => params['page'], 
  #     :conditions => "url is not null",
  #     :per_page => params[:limit] || DEFAULT_PER_PAGE, :order => 'url_access_at DESC'
  #   render :action => "index"
  # end
  
  def tagged
    @tag = params[:tag]
    @articles = @tag.empty? ?
      Article.paginate(page_opts) :
      Article.paged_find_tagged_with(@tag.split(/[\s　\+]+/), page_opts)
    render :action => 'index'
  end
  
  def viewed_at
    @articles = Article.paged_most_viewed_at params[:at], current_user, params[:page] || 1
    render :action => 'index'
  end
  
  private
  def page_opts
    {
      :page => params['page'], 
      :per_page => params[:limit] || DEFAULT_PER_PAGE
    }
  end  
  def viewed_timestamps
    session[:article_viewed_timestamp] ||= {}
  end
  
  def tags_string_to_tag_names(tags_string)
    tags_string.to_s.split(TAG_SEPARATOR).find_all{|tag|!tag.empty?}
  end
end
