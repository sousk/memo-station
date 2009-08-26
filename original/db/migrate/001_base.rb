class Base < ActiveRecord::Migration
  def self.up
    create_table "articles", :force => true do |t|
      t.column "subject", :string
      t.column "url", :string
      t.column "body", :text
      t.column "access_count", :integer, :default => 0
      t.column "access_date", :datetime
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "user_id", :integer
    end

    create_table "mailmessages", :force => true do |t|
      t.column "sender_name", :string, :default => "", :null => false
      t.column "email", :string, :default => "", :null => false
      t.column "subject", :string, :default => "", :null => false
      t.column "message", :text, :default => "", :null => false
      t.column "bcc_flag", :boolean, :default => false, :null => false
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end

    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data", :text
      t.column "updated_at", :datetime
    end

    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

    create_table "tags", :force => true do |t|
      t.column "name", :string
    end

    create_table "tags_articles", :id => false, :force => true do |t|
      t.column "article_id", :integer
      t.column "tag_id", :integer
    end

    create_table "user_infos", :force => true do |t|
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "name_kanji1", :string, :default => "", :null => false
      t.column "name_kanji2", :string, :default => "", :null => false
      t.column "name_kana1", :string, :default => "", :null => false
      t.column "name_kana2", :string, :default => "", :null => false
      t.column "post_code1", :string, :default => "", :null => false
      t.column "post_code2", :string, :default => "", :null => false
      t.column "prefecture_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "town_name", :string, :default => "", :null => false
      t.column "home_tel", :string, :default => "", :null => false
      t.column "mobile_tel", :string, :default => "", :null => false
      t.column "gender_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "birthday_date", :date
      t.column "email_delivery", :boolean
      t.column "pc_email", :string, :default => "", :null => false
      t.column "mobile_email", :string, :default => "", :null => false
      t.column "nickname", :string, :default => "", :null => false
      t.column "auto_login_flag", :boolean, :default => false, :null => false
      t.column "created_on", :datetime
      t.column "updated_on", :datetime
    end

    create_table "users", :force => true do |t|
      t.column "loginname", :string, :default => "", :null => false
      t.column "password", :string, :default => "", :null => false
      t.column "deleted", :boolean, :default => false, :null => false
    end
  end

  def self.down
    drop_table :articles
    drop_table :mailmessages
    drop_table :sessions
    drop_table :tags
    drop_table :tags_articles
    drop_table :user_infos
    drop_table :users
  end
end
