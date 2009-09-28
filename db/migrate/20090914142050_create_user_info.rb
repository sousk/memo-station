class CreateUserInfo < ActiveRecord::Migration
  def self.up
    create_table "user_infos" do |t|
      t.column "user_id", :integer, :limit => 10, :default => 0, :null => false
      t.column 'karma',   :integer, :default => 0
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
      t.timestamps
    end
  end

  def self.down
    drop_table :article_view_logs
  end
end
