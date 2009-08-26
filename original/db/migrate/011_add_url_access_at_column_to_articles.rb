class AddUrlAccessAtColumnToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :url_access_at, :timestamp, :null => true
  end

  def self.down
    remove_column :articles, :url_access_at
  end
end
