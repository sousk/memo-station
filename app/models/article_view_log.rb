class ArticleViewLog < ActiveRecord::Base
  belongs_to :article
  belongs_to :user
  
  DEFAULT_PERIOD = 1.month.ago
  DEFAULT_LIMIT = 10
  
  class << self
    def most_viewed_within(period=DEFAULT_PERIOD, limit=DEFAULT_LIMIT)
      find :all,
        :select => "article_id, count(id) as count",
        :include => :article,
        :conditions => ['created_at >= ?', period],
        :limit => limit,
        :group => 'article_id',
        :order => "count DESC"
    end
  end
end
