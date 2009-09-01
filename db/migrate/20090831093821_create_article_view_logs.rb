class CreateArticleViewLogs < ActiveRecord::Migration
  def self.up
    create_table "article_view_logs" do |t|
      t.integer "article_id"
      t.integer "user_id"
      t.timestamps
    end

  end

  def self.down
    drop_table :article_view_logs
  end
end
