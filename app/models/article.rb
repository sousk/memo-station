class Article < ActiveRecord::Base
  belongs_to :user
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :users, :through => :article_view_logs

  acts_as_taggable  # :join_table => "tags_articles"

  validates_presence_of :subject, :user_id, :my_tags
  validates_uniqueness_of :subject
  validates_uniqueness_of :url

  delegate :logger, :to => "self.class"
  delegate :debug, :to => "self.class.logger"
  
  class << self
    def latest(limit)
      Article.find(:all, :order => "created_at DESC", :limit => limit)
    end
    
    def most_viewed(before=1.years.ago, limit = 10, offset = 0)
      Article.find_by_sql(
        "select articles.*, count(article_view_logs.article_id) as article_id_count_all 
        from article_view_logs left join articles on articles.id = article_view_logs.article_id 
        WHERE article_view_logs.created_at >= '#{before}' group by article_view_logs.article_id 
        order by article_id_count_all DESC LIMIT #{offset},#{limit}")
    end
    
  end
end
