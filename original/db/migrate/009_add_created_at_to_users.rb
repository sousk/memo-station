class AddCreatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime

    UserInfo.reset_column_information
    User.reset_column_information
    User.find(:all).each{|user|
      user.created_at = user.user_info.created_on
      user.updated_at = user.user_info.created_on
      user.save_without_validation
    }
  end

  def self.down
    remove_column :users, :created_at
    remove_column :users, :updated_at
  end
end
