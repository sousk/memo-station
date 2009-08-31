class Article < ActiveRecord::Base
  belongs_to :user
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :users, :through => :article_view_logs

  acts_as_taggable :join_table => "tags_articles"

  validates_presence_of :subject, :user_id, :my_tags
  validates_uniqueness_of :subject
  validates_uniqueness_of :url

  delegate :logger, :to => "self.class"
  delegate :debug, :to => "self.class.logger"
  
  
  class << self
    def latest(limit)
      Article.find(:all, :order => "created_at DESC", :limit => limit)
    end
  end
end
