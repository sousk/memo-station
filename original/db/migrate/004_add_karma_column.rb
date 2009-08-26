class AddKarmaColumn < ActiveRecord::Migration
  def self.up
    add_column :user_infos, :karma, :integer, :default => 0
  end

  def self.down
    remove_column :user_infos, :karma
  end
end
