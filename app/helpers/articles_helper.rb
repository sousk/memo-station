module ArticlesHelper
  # def latest_articles
  #   Article.find(:all, :order => "created_at DESC", :limit => 10)
  # end  
  
  # def tags(article)
  #   article.tag_list.join(', ')
  # end
  
  def new_icon(article)
    if article.created_at && article.created_at >= 1.days.ago
      '<span class="new1">NEW</span>'
    elsif article.created_at && article.created_at >= 2.days.ago
      '<span class="new1">NEW</span>'
    else
      ""
    end
  end
  
  # 本文表示用
  #
  # 以前、次のようにしていたが問題がでてきた。
  #
  #   simple_format(auto_link(indent_by_escape(h(str.dup))))
  #
  # エスケープすると & が &amp; になりURLにふくまれる&が破壊されてしまう。
  # だから一端 & だけはもとに戻して auto_link に渡すようにした。
  def format_text(str)
    str = h(str).gsub(/&amp;/, "&")
    str = indent_by_escape(str)
    str = auto_link(str){|url|
      truncate(url, URL_TRUNCATE_LENGTH)
    }
    simple_format(str)
  end
  
  
  # def load_article(article, field)
  #   "if (Element.empty('#{field}')) {" +
  #     remote_function(:url => {:controller => "articles", :action => "show_remote", :id => article}) +t
  #   "} else {
  #     if (Element.visible('#{field}')) {
  #       $('#{field}').hide();
  #     } else {
  #       $('#{field}').show();
  #     }
  #   }"
  # end
end
