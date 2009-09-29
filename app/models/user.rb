require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  has_one :user_info
  has_many :articles
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :viewed_articles, :through => :article_view_logs, :source => :article
  delegate :karma, :to => :user_info


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def articles_count_average_per_day
    articles.count / alive_days
  end
  
  # how many day passed since user has been registered, in float
  def alive_days
    d = (Time.now - created_at).to_f / 1.day.to_f
    d > 1 ? d : 1.0;
  end
  
  def paged_recent_viewed(page=1, options = {})
    options = {
      :page => page || 1,
      :select => "articles.*, max(article_view_logs.created_at) as max_created_at", 
      :conditions => recent_viewed_conditions, 
      :group => "articles.id", :order => "max_created_at DESC"
    }.merge(options)
    viewed_articles.paginate(:all, options)
  end

  # def recent_viewed_count(options = {})
  #   viewed_articles.count({:distinct => true, :select => "articles.id", :conditions => recent_viewed_conditions}.merge(options))
  # end

  private
  def recent_viewed_conditions
    ["article_view_logs.created_at >= ?", 24.hours.ago]
  end
end
