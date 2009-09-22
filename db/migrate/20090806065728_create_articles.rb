class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.integer :user_id
      t.string :subject
      t.string :url
      t.text :body
      t.integer :access_count
      t.datetime :access_date
      t.timestamp :url_access_at, :null => true
      t.timestamp :modified_at, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
