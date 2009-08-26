class RemoveUserInfoColumns < ActiveRecord::Migration
  def self.up
    remove_column :user_infos, :name_kana1
    remove_column :user_infos, :name_kana2
    remove_column :user_infos, :post_code1
    remove_column :user_infos, :post_code2
    remove_column :user_infos, :prefecture_id
    remove_column :user_infos, :town_name
    remove_column :user_infos, :home_tel
    remove_column :user_infos, :mobile_tel
    remove_column :user_infos, :gender_id
    remove_column :user_infos, :birthday_date
    remove_column :user_infos, :email_delivery
    remove_column :user_infos, :nickname
  end

  def self.down
    add_column :user_infos, :name_kana1, :string, :default => "", :null => false
    add_column :user_infos, :name_kana2, :string, :default => "", :null => false
    add_column :user_infos, :post_code1, :string, :default => "", :null => false
    add_column :user_infos, :post_code2, :string, :default => "", :null => false
    add_column :user_infos, :prefecture_id, :string, :default => "", :null => false
    add_column :user_infos, :town_name, :string, :default => "", :null => false
    add_column :user_infos, :home_tel, :string, :default => "", :null => false
    add_column :user_infos, :mobile_tel, :string, :default => "", :null => false
    add_column :user_infos, :gender_id, :integer
    add_column :user_infos, :birthday_date, :timestamp, :default => "", :null => false
    add_column :user_infos, :email_delivery, :boolean
    add_column :user_infos, :nickname, :string, :default => "", :null => false
  end
end
