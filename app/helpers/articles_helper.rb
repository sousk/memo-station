module ArticlesHelper
  def latest_articles
    Article.find(:all, :order => "created_at DESC", :limit => 10)
  end
end
