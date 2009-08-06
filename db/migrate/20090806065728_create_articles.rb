class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :subject
      t.string :url
      t.text :body
      t.integer :access_count
      t.datetime :access_date

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
