class MailmessageDrop < ActiveRecord::Migration
  def self.up
    drop_table :mailmessages
  end

  def self.down
    raise IrreversibleMigration
  end
end
