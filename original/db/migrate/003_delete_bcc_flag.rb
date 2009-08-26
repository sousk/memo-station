class DeleteBccFlag < ActiveRecord::Migration
  def self.up
    remove_column :mailmessages, :bcc_flag
  end

  def self.down
    add_column :mailmessages, :bcc_flag, :boolean, :default => false, :null => false
  end
end
