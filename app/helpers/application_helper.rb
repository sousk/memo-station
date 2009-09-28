module ApplicationHelper
  include TagsHelper

  def icon_tag(name)
    image_tag("/silk_icons/#{name}.png", :class => "silk_icon icon_#{name}")
  end

  def tag_item_url(options)
    url_for(:controller => "articles", :action => "search", :tag => options[:tag])
  end

  def my_form_elements_start
    "<dl>"
  end

  def my_form_elements_end
    "</dl>"
  end

  def my_text_label(model, column)
    "<label class=\"label\" for=\"#{model}_#{column}\">" + model.to_s.camelize.constantize.human_attribute_name(column) + "</label>"
  end

  def my_text_field(model, column)
    my_form_element(my_text_label(model, column), text_field(model.to_sym, column))
  end

  def my_column_show(model, column)
    my_form_element(model.to_s.camelize.constantize.human_attribute_name(column), eval("@#{model}.#{column}"))
  end

  def my_form_element(left_head, right_value)
    str = ""
    str << "<dt>#{left_head}</dt>\n"
    str << "<dd>#{right_value}</dd>\n"
    str
  end

  # 先頭のインデントのみ対応。
  # 行頭以外のスペースも置き換えてみたけど結局は固定幅のフォントを使わないとずれてしまうので意味がない。
  # それにEmacsで読むときに取り込みやすいかどうかが重要なのでWEBでの見え方はそれほど拘らなくてもよい。
  def indent_by_escape(str)
    str.gsub(/^ +/){|m|"&nbsp;" * m.length}
  end

  # 本文表示用
  #
  # 以前、次のようにしていたが問題がでてきた。
  #
  #   simple_format(auto_link(indent_by_escape(h(str.dup))))
  #
  # エスケープすると & が &amp; になりURLにふくまれる&が破壊されてしまう。
  # だから一端 & だけはもとに戻して auto_link に渡すようにした。
  def article_simple_format(str)
    str = h(str).gsub(/&amp;/, "&")
    str = indent_by_escape(str)
    str = auto_link(str){|url|
      truncate(url, URL_TRUNCATE_LENGTH)
    }
    simple_format(str)
  end

  # ブックマークレットの指定
  #
  # ソースはスペース圧縮しない形でテンプレートディレクトリに置いておく。
  # それからコメントを外して圧縮して出力する。
  #
  # For example:
  #
  #   <%= link_to "新規メモ", bookmarklet_javascript('articles/bookmarklet') %>
  #
  def bookmarklet_javascript(template, options = {})
    options = {:cleanup => true}.merge(options)
    template_file = Pathname("#{RAILS_ROOT}/app/views/#{template}.js")
    erb = ERB.new(template_file.read)
    source = erb.result(binding)
    if options[:cleanup]
      source = "javascript:" + source.gsub(%r{^\s*//.*$}, "").collect{|line|line.strip}.to_s
    end
    source
  end

  # アイコン付き link_to
  def link_to_with_icon(icon_name, name, options = {}, html_options = nil, *parameters_for_method_reference)
    icon_link = link_to(icon_tag(icon_name), options, html_options, *parameters_for_method_reference)
    name_link = link_to(name, options, html_options, *parameters_for_method_reference)
    icon_link + name_link
  end

  # アイコン付き link_to
  def link_to_remote_with_icon(icon_name, name, options = {}, html_options = nil, *parameters_for_method_reference)
    icon_link = link_to_remote(icon_tag(icon_name), options, html_options, *parameters_for_method_reference)
    name_link = link_to_remote(name, options, html_options, *parameters_for_method_reference)
    icon_link + name_link
  end

  # アイコン付き link_to
  def link_to_function_with_icon(icon_name, name, options = {}, html_options = nil, *parameters_for_method_reference)
    icon_link = link_to_function(icon_tag(icon_name), options, html_options, *parameters_for_method_reference)
    name_link = link_to_function(name, options, html_options, *parameters_for_method_reference)
    icon_link + name_link
  end


  # 管理者か？
  def superuser?
    session[:user] && session[:user].superuser?
  end

  # JavaScript の search_plugin_add を呼び出す
  # see: ~/src/memo_station/public/javascripts/application.js
  #
  # For exsample:
  #
  #   <%= button_to_function("はい", search_plugin_add) %>
  #
  def search_plugin_add
    "
if (!search_plugin_add_check()) {
    alert('このブラウザには対応していません。');
    return false;
}
search_plugin_add('#{search_plugin_path("src")}', '#{search_plugin_path("png")}', '#{APPLICATION_TITLE}', '情報');
alert('追加しました。');
  "
  end

  # "http://〜/" を返す。
  def server_root_path
    "#{request.protocol}#{request.host_with_port}/"
  end

  # 検索プラグインへのURLを返す。
  def search_plugin_path(extname)
    raise ArgumentError unless %w(src png gif).include?(extname)
    "#{server_root_path}#{SEARCH_PLUGIN_NAME}.#{extname}"
  end

  # 開発環境か?
  # local_request? を使う方法もある。
  def development?
    ENV["RAILS_ENV"] == "development"
  end

  # Operaブラウザーか？
  def opera?
    request.env["HTTP_USER_AGENT"].to_s.match(/\bOpera\b/io)
  end

  # フルパスでURLを生成する
  # typoより
  def server_url_for(options = {})
    controller.url_for(options.merge(:only_path => false))
  end
end
