class ArticlesController < ApplicationController
  def index
    @article_pages = Article.paginate :page => params['page'], :order => 'updated_at DESC'
  end
end
