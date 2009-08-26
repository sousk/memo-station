class RemoveUserInfoAutoLoginFlag < ActiveRecord::Migration
  def self.up
    remove_column :user_infos, :auto_login_flag
  end

  def self.down
    add_column :user_infos, :auto_login_flag, :boolean
  end
end
