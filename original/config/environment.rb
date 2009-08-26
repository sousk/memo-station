$KCODE = "utf8"

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

#
# routes.rb の中でも使う場合はここに記述しないと反映されない。
#
APPLICATION_TITLE   = "バッドノウハウの杜" # タイトル
TAG_SEPARATOR       = %r/[　\s,;]+/        # 消極的なXSS対策のために<>を含めようかと思ったけどやっぱやめた
TAG_TOGGLE_MODE     = :remote              # :remote or :client
ENCODING_UTF8       = "w"                  # UTF-8をu以外で表わすときの文字(Chasenとかnkf用)
SEARCH_PLUGIN_NAME  = "bk-forest"          # routes.rb の中で参照するため上の方で書く。
URL_TRUNCATE_LENGTH = 64                   # URLを表示する最大サイズ

if `hostname`.strip == 'dimension'
  AdminName = "池田 晃"
  AdminMail = "ikeda@localhost"
else
  AdminName = "塙与志夫"
  AdminMail = "hanawa@dino.co.jp"
end

AuthorMail = "hanawa@dino.co.jp"
AuthorName = "塙与志夫"

Rails::Initializer.run do |config|
  # ログの色付け
  config.active_record.colorize_logging = true

  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :article, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
gem "acts_as_taggable"

ActiveRecord::Base.connection.execute("set names #{$KCODE}")
ActiveRecord::Base.connection.execute("set wait_timeout = #{1.week}") # これを入れないと数時間で繋がらなくなる


# アップロード不具合対策
# http://dev.mysql.com/doc/refman/4.1/ja/packet-too-large.html
#
# ■現象
# 1M以上のファイルをアップロードすると長いinsert文が発行され次のエラーになる。
# Mysql::Error: Got a packet bigger than 'max_allowed_packet' bytes: INSERT INTO bbs_articles〜(略)
#
# ■原因
# mysqlのデフォルトでは max_allowed_packet の値が約1Mになっている。
# $ mysql -u root ttclub -e 'show variables' | grep max_allowed_packet
# | max_allowed_packet              | 1048576                                                   |
#
# ■対策
# 制限をアップロードするファイル以上に設定する。
ActiveRecord::Base.connection.execute("set max_allowed_packet = #{100.megabytes}")



# Rails::Initializer.run do |config|
#   config.action_controller.session_store = :active_record_store
# end


# Include your app's configuration here:


# SMTPサーバ利用時のオプション
ActionMailer::Base.server_settings = {
  :address        => 'localhost', # default: localhost
  :port           => '25',        # default: 25
  :domain         => 'localhost', # HELO domain を指定する場合
#   :user_name      => 'user',
#   :password       => 'pass',
  :authentication => :plain       # :plain, :login or :cram_md5
}

# 配送に失敗したら例外を出す
# ActionMailer::Base.raise_delivery_errors = true

# 配送手段を :smtp か :sendmail から明示する。
# :sendmail の場合は "/usr/sbin/sendmail"(変更不可) が利用される。
ActionMailer::Base.delivery_method = :smtp     # default :smtp

# 実際の配送処理を行うかどうか。(ほぼテスト用)
# ActionMailer::Base.perform_deliveries = true      # default: true

# テスト時に配送したメールの配列を保存する。
ActionMailer::Base.deliveries = []

# subject と body のエンコードに利用される文字コード。@charset でも指定可能。
ActionMailer::Base.default_charset = 'iso-2022-jp' # default: 'UTF-8'

# デフォルトの content-type を指定する。@content_type でも指定可能。
# ActionMailer::Base.default_content_type = ...      # default: 'text/plain'

# 暗黙的に multi-part が作成されたときの並び順。@implicit_parts_order でも指定可能。
ActionMailer::Base.default_implicit_parts_order =["text/html", "text/enriched", "text/plain"]

require 'acts_as_versioned'

require 'pp'

def db_query(query)
  puts `mysql -u root #{ActiveRecord::Base.configurations[RAILS_ENV]["database"]} -te '#{query}'`
end

require 'active_record_fixture'

MyConfig = {
  :search_remote_flag => true,
}

require 'action_pack'

module ActionView::Helpers::TextHelper
  # Extracts an excerpt from the +text+ surrounding the +phrase+ with a number of characters on each side determined
  # by +radius+. If the phrase isn't found, nil is returned. Ex:
  #   excerpt("hello my world", "my", 3) => "...lo my wo..."
  def excerpt(text, phrase, radius = 100, excerpt_string = "...")
    if text.nil? || phrase.nil? then return end
    phrase = Regexp.escape(phrase)
    if md = %r/(#{phrase})/i.match(text)
      pre_chars = md.pre_match.split(//)
      pre_str = pre_chars.last(radius).join.lstrip
      pre_excerpt_str = excerpt_string if pre_chars.size > radius
      post_chars = md.post_match.split(//)
      post_str = post_chars.first(radius).join.rstrip
      post_excerpt_str = excerpt_string if post_chars.size > radius
      "#{pre_excerpt_str}#{pre_str}#{md.captures}#{post_str}#{post_excerpt_str}"
    end
  end
end

# Chasen
# コントーラの中で Chasen.getopt を呼ぶと environment.rb が毎回ロードされた。
# environment.rb の中で呼ぶとループしてしまい起動しなくなる。
# 原因不明
if false
  require "chasen"
  Chasen.getopt(*[["-F", "%m,%H\n"], ["-j"], ["-i", ENCODING_UTF8]].flatten)
end

# PDF::Writer
# 以下のエラーが大量にでるため silence_warnings で抑制
# transaction-simple-1.3.0/lib/transaction/simple.rb:74: warning: already initialized constant Messages
RAILS_DEFAULT_LOGGER.around_info("---- PDF::Writer start ----", "---- PDF::Writer end ----") {
  begin
    silence_warnings {
      require "pdf/writer"
    }
    $pdf_writer_loaded = true
  rescue LoadError, NoMethodError
    RAILS_DEFAULT_LOGGER.info("Error: #{$!}")
  end
  if defined? PDF::Writer
    RAILS_DEFAULT_LOGGER.info("OK")
  else
    RAILS_DEFAULT_LOGGER.info("NG")
  end
}

# RailsTidy
# RAILS_DEFAULT_LOGGER.around_info("---- RaildTidy start ----", "---- RaildTidy end ----") {
#   unless defined? RailsTidy
#     RAILS_DEFAULT_LOGGER.info("RailsTidy は require されていないのでスキップします。")
#   else
#     unless Pathname(RailsTidy.tidy_path).exist?
#       raise "#{RailsTidy.tidy_path} が見つかりません。"
#     end
#     RAILS_DEFAULT_LOGGER.info("OK")
#   end
# }

require "sparklines"
require "gruff"
require "memo_station_util"

RAILS_DEFAULT_LOGGER.info("loaded: #{__FILE__}")
