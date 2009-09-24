module ArticlesHelper
  def latest_articles
    Article.find(:all, :order => "created_at DESC", :limit => 10)
  end  
  
  def new_icon(article)
    if article.created_at && article.created_at >= 1.days.ago
      '<span class="new1">NEW</span>'
    elsif article.created_at && article.created_at >= 2.days.ago
      '<span class="new1">NEW</span>'
    else
      ""
    end
  end
end
