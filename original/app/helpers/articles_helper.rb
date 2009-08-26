module ArticlesHelper
  def other_search_url_for(*tag_names)
    "http://www.google.co.jp/search?complete=1&hl=ja&lr=lang_ja&q=#{tag_names.flatten.join(" ")}"
  end
end
