# Schema as of 2006/08/01 06:58:50 (schema version 9)
#
#  id                  :integer(11)   not null
#  subject             :string(255)   
#  url                 :string(255)   
#  body                :text          
#  access_count        :integer(11)   default(0)
#  access_date         :datetime      
#  created_at          :datetime      
#  updated_at          :datetime      
#  user_id             :integer(11)   
#  modified_at         :datetime      not null
#

class Article < ActiveRecord::Base
  belongs_to :user
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :users, :through => :article_view_logs

  acts_as_taggable :join_table => "tags_articles"

  validates_presence_of :subject, :user_id, :my_tags
  validates_uniqueness_of :subject

  delegate :logger, :to => "self.class"
  delegate :debug, :to => "self.class.logger"


  # るびまの記事からメモした場合には同じURLで複数登録してしまうことがある。
  # なのでURL重複チェックは入れないほうがいい。
  # と、判断したものの、重複して登録できるメリットより、
  # 間違って重複させてしまうデメリットの方が大きいような気もする。
  # 現状、すでに重複したURLが入ってしまっているので、とりあえず重複チェックはやめにする。
  if false
    validates_uniqueness_of :url, :if => Proc.new{|article|!article.url.blank?}
  end

  # Emacsからポストできる正しいテキストかを確認する
  def self.text_format_ok?(article_str)
    article_str.include?("Subject:") && article_str.include?("Tag:") && article_str.include?("From:")
  end

  # ポストされたテキストから使えるものだけを抽出する
  def self.text_post_cleanup(articles_str)
    articles = articles_str.split(/^-{80,}$/)
    articles.find_all{|article|text_format_ok?(article)}
  end

  # ポストしたテキストをまとめて処理する
  def self.text_post(articles_str)
    out = ""
    articles = text_post_cleanup(articles_str)
    out << "個数: #{articles.size}\n"
    out << "#{articles.inspect}\n" if $DEBUG
    logger.debug(articles)
    articles.each{|article|
      out << self.text_post_one(article)
    }
    out
  end

  # 一つの記事だけを処理する
  def self.text_post_one(article_str)
    article_str = article_str.toutf8
    if md = article_str.match(/^Id:[ \t]*(\d+)$/i)
      id = md.captures.first.to_i
    end
    if md = article_str.match(/^Subject:[ \t]*(.+)$/i)
      subject = md.captures.first.ja_clean
    end
    if md = article_str.match(/^Url:[ \t]*(.+)$/i)
      url = md.captures.first.ja_clean
    end
    if md = article_str.match(/^Tag:[ \t]*(.+)$/i)
      tag = md.captures.first.ja_clean
    end
    if md = article_str.match(/^From:[ \t]*(.+)$/i)
      from = md.captures.first.ja_clean
    end
    if md = article_str.match(/^--text follows this line--\n(.*)\z/mi)
      contents = md.captures.first.ja_strip
    end
    if id
      obj = Article.find(id)
      pre_obj = obj.clone
    else
      obj = Article.new
    end
    obj.attributes = {:subject => subject, :body => contents, :url => url}
    obj.my_tags = tag
    obj.user = User.find_by_loginname(from)
    if obj.new_record?
      do_save = true
    else
      unless obj.contents_equal?(pre_obj)
        do_save = true
      end
    end
    if do_save
      if obj.new_record?
        status = "create"
      else
        status = "update"
      end
      if obj.save
        save_result = "OK"
      else
        save_result = "Error"
      end
    else
      status = "skip"
    end
    "#{obj.id}: #{obj.subject} #{status} #{save_result}".rstrip + "\n"
  end

  # sparklines 用(FIXME: cast を使わない方法に治す)
  def self.distribution
    articles = self.count(:group => "cast(created_at as date)")
    logger.debug(articles.inspect)
    distribution = []
    (Time.now.beginning_of_day.months_ago(1).to_date .. Time.now.beginning_of_day.to_date).each{|day|
      count = 0
      if find = articles.assoc(day.to_s)
        count = find.last
      end
      distribution << count
    }
    distribution
  end

  # MySQLでエクスポートするときのテンポラリファイル名
  # [RAILS_ROOT]/tmp にすると権限の問題で書けないことがあるので /tmp に変更
  def self.export_mysql_csv_path
    if false
      Pathname("#{RAILS_ROOT}/tmp/export.csv.#{create_new_id}").expand_path
    else
      Pathname("/tmp/export.csv.#{create_new_id}").expand_path
    end
  end

  # MySQLの機能を使って直接CSVエクスポート
  # 高速に処理できるけどテーブルをまたぐデータを履かせるのが大変
  def self.export_mysql_csv
    path = export_mysql_csv_path
    connection.execute(%Q(select a.id, a.subject, a.url, u.loginname, a.body, a.access_count, a.created_at into outfile #{connection.quote(path.to_s)} fields terminated by ',' optionally enclosed by '"' escaped by '' lines terminated by '\n' from articles as a, users as u where a.user_id = u.id))
    path
  end

#   # 人気メモ
#   def self.most_viewed(options = {})
#     options = {:order => "access_count DESC, created_at DESC", :limit => 10}.merge(options)
#     find(:all, options)
#   end

  # 人気メモ数
  def self.most_viewed_count(before_time)
#     ArticleViewLog.count(:distinct => true, :select => "article_id")
#     raise ArticleViewLog.count("distinct article_id", :conditions => nil).inspect
    ArticleViewLog.count(:distinct => true, :select => "article_id", :conditions => ["created_at >= ?", before_time])
#     ArticleViewLog.count("distinct article_id", :conditions => ["created_at >= ?", before_time])
  end

  # 人気メモ
  def self.most_viewed(before_time, options = {})
    Article.find_by_sql("select articles.*, count(article_view_logs.article_id) as article_id_count_all from article_view_logs left join articles on articles.id = article_view_logs.article_id WHERE article_view_logs.created_at >= '#{before_time}' group by article_view_logs.article_id order by article_id_count_all DESC LIMIT #{options[:offset]},#{options[:limit]}")
  end

  # ToDo: urlの正規化
  def before_validation
    self.subject = self.subject.to_s.ja_clean
    if self.url
      self.url = self.url.to_s.ja_strip.sub(%r{^h?t?tp(s?)://}io, 'http\1://')
    end
    self.body = self.body.to_s.map{|line|line.ja_rstrip + "\n"}.to_s.strip
  end

  def before_save
    self.access_date ||= Time.now
    self.modified_at ||= Time.now
    if self.url.blank?
      self.url = nil
      self.url_access_at = nil
     else
      self.url_access_at ||= Time.now
    end
  end

  # bodyかurlが変更されたときのみ modified_at を更新する。
  def before_update
    pre_article = self.class.find(self.id)
    if pre_article.body != self.body || pre_article.url != self.url
      self.modified_at = Time.now
    end
  end

  # フォーム用
  def my_tags
    self.tag_names * " "
  end

  def my_tags=(tags)
    self.tag(tags, :clear => true, :separator => proc{|t|t.split(TAG_SEPARATOR)})
  end

  # other の tag_names は常に空。比較はできないので注意。
  def contents_equal?(other)
    self.subject == other.subject &&
      self.body == other.body &&
      self.url == other.url
  end

  def to_text
    str = ""
    str << "Id: #{self.id}\n" unless self.new_record?
    str << "Subject: #{self.subject}\n"
    str << "Url: #{self.url}\n"
    str << "From: #{self.user.loginname}\n"
    str << "Tag: #{self.my_tags}\n"
    str << "Created at: #{self.created_at}\n" unless self.new_record?
    str << "--text follows this line--\n"
    str << "#{self.body}\n"
    str
  end

  # CSV出力用データ
  def export_row
    [id, subject, url, user.loginname, my_tags, body, access_count, created_at]
  end

  private
  # MySQLでCSVを吐くのときのテンポラリファイル用
  def self.create_new_id
    require "digest/md5"
    md5 = Digest::MD5::new
    now = Time.now
    md5.update(now.to_s)
    md5.update(now.usec.to_s)
    md5.update(rand.to_s)
    md5.update($$.to_s)
    md5.hexdigest
  end
end
