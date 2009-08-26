# Schema as of 2006/08/01 06:58:50 (schema version 9)
#
#  id                  :integer(11)   not null
#  loginname           :string(255)   default(), not null
#  password            :string(255)   default(), not null
#  deleted             :boolean(1)    not null
#  created_at          :datetime      
#  updated_at          :datetime      
#

require 'digest/sha1'

class User < ActiveRecord::Base
  has_one :user_info
  has_many :articles
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :viewed_articles, :through => :article_view_logs, :source => :article
  delegate :karma, :to => :user_info

  # パスワードを暗号化するときにアプリ毎にユニークにするための文字列
  @@salt = 'memo_station'
  cattr_accessor :salt

  # ユーザー認証
  def self.authenticate(loginname, password)
    find_first(["loginname = ? AND password = ?", loginname, sha1(password)])
  end

  # 作成時に関連するテーブルを作成
  def after_create
    super
    raise if self.has_user_info?

    user_info = self.build_user_info
    user_info.save!

    raise unless self.has_user_info?
  end

  def nickname
    if self.has_user_info? && !self.user_info.nickname.blank?
      self.user_info.nickname
    else
      self.loginname
    end
  end

  def realname
    if self.has_user_info? && !self.user_info.name_kanji1.blank?
      self.user_info.name_kanji1
    else
      self.nickname
    end
  end

  def superuser?
    %w(admin).include?(self.loginname)
  end

  # 一日の平均メモ数
  def articles_count_average_per_day
    articles.count / alive_days
  end

  # 登録してから何日たっているか？(小数)
  def alive_days
    (Time.now - created_at) / 1.days
  end

  # 最近見た履歴の数(重複なし)
  def recent_viewed_count(options = {})
    viewed_articles.count({:distinct => true, :select => "articles.id", :conditions => recent_viewed_conditions}.merge(options))
  end

  # 最近見た履歴(重複なし・最近見た順)
  #
  # mysql -u root memo_station_production -e 'select articles.id,articles.subject,max(article_view_logs.created_at) as created_at_max  from articles inner join article_view_logs on articles.id = article_view_logs.article_id where (article_view_logs.user_id = 1) group by articles.id order by created_at_max desc'
  #
  def recent_viewed(options = {})
    options = {:select => "articles.*, max(article_view_logs.created_at) as max_created_at", :conditions => recent_viewed_conditions, :group => "articles.id", :order => "max_created_at DESC"}.merge(options)
    viewed_articles.find(:all, options)
  end

  # 最近見た履歴用の条件
  def recent_viewed_conditions
    ["article_view_logs.created_at >= ?", 24.hours.ago]
  end

  protected

  # 指定文字列のハッシュ化
  def self.sha1(pass)
    Digest::SHA1.hexdigest("#{salt}--#{pass}--")
  end

  before_create :crypt_password

  # INSERTする前にパスワードを暗号化
  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end

  before_update :crypt_unless_empty

  # UPDATEする前にパスワードを暗号化
  # もしパスワードが空になっていたらDBに格納している値で復活させる。
  # つまり絶対にパスワードが空になることはない。
  def crypt_unless_empty
    if password.empty?
      user = self.class.find(self.id)
      self.password = user.password
    else
      write_attribute "password", self.class.sha1(password)
    end
  end

  # ログイン名は登録するときにだけユニークであればよい。
  # 一旦登録すると重複するログイン名が可能になる。
  validates_uniqueness_of :loginname, :on => :create

  validates_confirmation_of :password
  # validates_length_of :loginname, :within => 3..40
  # validates_length_of :password, :within => 4..20
  validates_presence_of :loginname, :password, :password_confirmation

  def validate
    errors.add_on_boundary_breaking(:loginname, 3..40) unless errors.invalid?(:loginname)
    errors.add_on_boundary_breaking(:password, 1..20) unless errors.invalid?(:password)
  end

end
