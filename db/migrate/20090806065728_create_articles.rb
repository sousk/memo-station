class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.integer :user_id
      t.string :subject
      t.string :url
      t.text :body
      t.integer :access_count, :default => 0
      t.datetime :access_date
      t.timestamp :url_access_at, :null => true

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
