class Article < ActiveRecord::Base
  acts_as_taggable
  
  belongs_to :user
  has_many :article_view_logs, :order => "created_at DESC"
  has_many :users, :through => :article_view_logs

  validates_presence_of :subject, :user_id, :my_tags
  validates_uniqueness_of :subject

  validates_presence_of :subject, :user_id, :my_tags
  validates_uniqueness_of :subject

  DEFAULT_PERIOD = 1.month.ago
  DEFAULT_LIMIT = 10

  class << self
    def most_viewed_within(period=DEFAULT_PERIOD, limit=DEFAULT_LIMIT)
      Article.find :all,
        :select => "a.*, count(l.article_id) as count",
        :group => "l.article_id",
        :joins => "as a left join article_view_logs as l on a.id = l.article_id",
        :conditions => ["l.created_at >= ?", period],
        :limit => limit,
        :order => "count DESC"
    end
    
    def latest(limit=10)
      Article.find(:all, :order => "created_at DESC", :limit => limit)
    end
    
    def get(id, visitor)
      article = Article.find(id)
      if article
        article.update_attribute(:access_date, Time.now)
        article.access_count ||= 0
        article.access_count += 1
      end
      
      if visitor
        article.article_view_logs.create! :user => visitor
      end
      
      article
    end
    
    def paged_find_tagged_with(tags, args = {})
      if tags.blank?
        paginate args
      else
        opts = find_options_for_find_tagged_with(tags, :match_all => true).merge(args)
        paginate opts
      end
    end
    
    def most_viewed(before=1.years.ago, limit = 10, offset = 0)
      Article.find_by_sql(
        "select articles.*, count(article_view_logs.article_id) as article_id_count_all 
        from article_view_logs left join articles on articles.id = article_view_logs.article_id 
        WHERE article_view_logs.created_at >= '#{before}' group by article_view_logs.article_id 
        order by article_id_count_all DESC LIMIT #{offset},#{limit}")
    end
    
    def most_viewed_with_paginate(before=1.years.ago, page=1, per_page=10)
      Article.paginate_by_sql [
        "select articles.*, count(article_view_logs.article_id) as article_id_count_all 
        from article_view_logs left join articles on articles.id = article_view_logs.article_id 
        WHERE article_view_logs.created_at >= ? group by article_view_logs.article_id 
        order by article_id_count_all DESC", before
      ], :page => page, :per_page => per_page
    end
  end
    
  # update :modified_at only when body or url has been changed
  def before_update
    pre_article = self.class.find(self.id)
    if pre_article.body != self.body || pre_article.url != self.url
      self.modified_at = Time.now
    end
  end
  
  # for form object
  def my_tags
    # self.tag_names * " "
    self.tag_list.join(',')
  end

  def my_tags=(tags)
    self.tag(tags, :clear => true, :separator => proc{|t|t.split(TAG_SEPARATOR)})
  end
end

