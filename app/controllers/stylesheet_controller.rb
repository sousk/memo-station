=begin

動的スタイルシート

使い方

<%= stylesheet_link_tag(url_for(:controller => "stylesheet", :action => "style")).gsub(/\.css/, "")  %>
これで app/views/stylesheet/style.rhtml が読みこまれるようになる。

備考

url_for は /stylesheet/style のURLを生成してくれる。しかし、stylesheet_link_tag
は拡張子が付いていなければ .css を付加しやがって /stylesheet/style.css になって
しまい、存在しない静的ファイルを読もうとしてしまう。それに対処するために最後で
.css を gsub で消している。

その他

stylesheet_controller.rb の名前はそのままにしておきたいが、静的ディレクトリの
stylesheets と似ていて分かりにくい面もあるので、URLの表記だけ変えたいという場合
は、次のように controller 名を変える。

<%= stylesheet_link_tag(url_for(:controller => "css", :action => "style")).gsub(/\.css/, "")  %>

そして次のように ~/src/ttclub/config/routes.rb に置き換えルールを追加する。

ActionController::Routing::Routes.draw do |map|
  map.connect 'css/:action', :controller => 'stylesheet'
end

=end

class StylesheetController < ApplicationController
  # caches_page :admin

  layout nil                    # Application.rhtml の影響を受けないようにする。

  after_filter{|c|
    c.headers["Content-Type"] = 'text/css' # lighttpdのデフォルトだとCSSと判断されていないので明示的に指定する。
    # c.response.body = c.response.body.toutf8 # FireFox のエディット画面で見れるように UTF-8 にする。
  }
end
