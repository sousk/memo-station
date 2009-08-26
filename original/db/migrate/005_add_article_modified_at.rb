class AddArticleModifiedAt < ActiveRecord::Migration
  def self.up
    add_column :articles, :modified_at, :timestamp, :null => false
    Article.reset_column_information
    Article.update_all ['modified_at = ?', Time.now]
  end

  def self.down
    remove_column :articles, :modified_at
  end
end
