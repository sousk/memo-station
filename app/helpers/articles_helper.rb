module ArticlesHelper
  def hoge
    "hogehoge"
  end
  
  def latest_articles
    Article.find(:all, :order => "created_at DESC", :limit => 10)
  end
end
