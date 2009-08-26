class ArticleUrlNullSet < ActiveRecord::Migration
  def self.up
    Article.transaction {
      Article.find(:all).each{|article|
        article.save!
      }
    }
  end

  def self.down
  end
end
