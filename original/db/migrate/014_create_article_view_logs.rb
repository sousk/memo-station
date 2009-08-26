class CreateArticleViewLogs < ActiveRecord::Migration
  def self.up
    create_table "article_view_logs" do |t|
      t.column "article_id", :integer
      t.column "user_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

  end

  def self.down
    create_table :article_view_logs
  end
end
