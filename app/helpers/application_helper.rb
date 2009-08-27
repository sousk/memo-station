# The methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  # トピックパスに表示しないコントローラー名

  @@topic_path_hide_controllers = ["articles", "account"]

  # http://wota.jp/ac/?date=200508
  def template_error_messages_for (object_name, options = {})
    options = options.symbolize_keys
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      render :partial => "system/error_messages_for", :locals => {:messages => object.errors.full_messages, :object => object}
    end
  end

  # Returns a string containing the error message attached to the +method+ on the +object+, if one exists.
  # This error message is wrapped in a DIV tag, which can be specialized to include both a +prepend_text+ and +append_text+
  # to properly introduce the error and a +css_class+ to style it accordingly. Examples (post has an error message
  # "can't be empty" on the title attribute):
  #
  #   <%= error_message_on "post", "title" %> =>
  #     <div class="formError">can't be empty</div>
  #
  #   <%= error_message_on "post", "title", "Title simply ", " (or it won't work)", "inputError" %> =>
  #     <div class="inputError">Title simply can't be empty (or it won't work)</div>
  def my_error_message_on(object, method, prepend_text = instance_variable_get("@#{object}").class.human_attribute_name(method), append_text = "", css_class = "formError")
    error_message_on(object, method, prepend_text, append_text, css_class)
  end

  # 常に表示するメニュー
  def content_for_global_navi
    ary = []

    if controller.my_category == "articles" && controller.action_name == "new"
      class_name = "activeNavi"
    else
      class_name = "nonActive"
    end

    ary << link_to(icon_tag("page_white_edit") + "新規メモ", {:controller => "articles", :action => "new"}, {:class => class_name})

    if controller.my_category == "articles" && (controller.action_name == "index" || controller.action_name == "list")
      class_name = "activeNavi"
    else
      class_name = "nonActive"
    end

    ary << link_to(icon_tag("book_open") + "メモ一覧", {:controller => "articles", :action => "list"}, {:class => class_name})


    if development? || controller.local_request? || (session[:user] && session[:user].loginname == "ikeda")
      if controller.my_category == "articles" && (controller.action_name == "bookmark")
        class_name = "activeNavi"
      else
        class_name = "nonActive"
      end

      ary << link_to(icon_tag("world") + "ブックマーク", {:controller => "articles", :action => "bookmark"}, {:class => class_name})
    end

    content_tag("ul", ary.collect{|elem|content_tag("li", elem)}.join, :id => "globalNavi")
  end

  # サイドバーに表示するメニュー
  def content_for_sub_navi
    content = ""
    case controller.my_category
    when "mypage"
      content << content_tag("dd", link_to(icon_tag("vcard") + "プロフィール", {:controller => "user_info", :action => "profile", :id => session[:user]}))
      content << content_tag("dd", link_to(icon_tag("user") + "ユーザー情報表示", {:controller => "user_info", :action => "show", :id => session[:user]}))
      content << content_tag("dd", link_to(icon_tag("user_edit") + "ユーザー情報編集", {:controller => "user_info", :action => "edit"}))
    end
    return if content.empty?
    content_tag("dl", content, :class => "simple_navi")
  end

  # パンクズリスト
  def topic_path_list
    paths = []
    paths << link_to("トップ", :controller => "")
    unless @@topic_path_hide_controllers.include?(controller.controller_name)
      unless controller.my_category.blank?
        paths << link_to(controller.my_category.humanize, :controller => controller.my_category)
      end
    end
    if @topic_path_last
      paths += @topic_path_last.to_a
    end
    paths.join(html_escape(" > ")) + "\n" + "<!-- topic_path=[#{strip_tags(paths.join(","))}] -->\n"
  end


  #アイコン用を簡単に表示
  def icon_tag(name)
    image_tag("/silk_icons/#{name}", :class => "silk_icon icon_#{name}")
  end

  # タグクラウド
  # http://blog.craz8.com/articles/2005/10/28/acts_as_taggable-is-a-cool-piece-of-code
  def tag_cloud(tag_cloud, category_list)
    max, min = 0, 0
    tag_cloud.each_value do |count|
      max = count if count > max
      min = count if count < min
    end

    divisor = ((max - min) / category_list.size) + 1

    tag_cloud.each do |tag, count|
      yield tag, count, category_list[(count - min) / divisor]
    end
  end

  def tag_item_url(options)
    url_for(:controller => "articles", :action => "search", :query => options[:query])
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

  # タイトルタグの中に入れる文字列を返す。
  def application_title
    titles = [APPLICATION_TITLE]
    unless @@topic_path_hide_controllers.include?(controller.my_category)
      unless controller.my_category.blank?
        titles << controller.my_category.humanize
      end
    end
    unless @page_title.blank?
      titles << @page_title
    end
    titles.reverse * " - "
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

  # カスタム submit_tag
  #
  # Operaはclick時にthis.disabled=trueを実行するとWRONG_ARGUMENTS_ERRで止まる。
  # Opera Version 9.01 で起きた現象。
  #
  # なのでOperaではdisable_withがあると無効にしてかわりにhideする。
  #
  # 荒殿さんからの報告
  def my_submit_tag(*args)
    options = args.pop
    if opera?
      if disable_with = options.delete(:disable_with)
        options[:onclick] = "this.hide();new Insertion.After(this, '#{disable_with}');#{options[:onclick]}"
      end
    end
    submit_tag(*(args + [options]))
  end

  # フルパスでURLを生成する
  # typoより
  def server_url_for(options = {})
    controller.url_for(options.merge(:only_path => false))
  end
end
