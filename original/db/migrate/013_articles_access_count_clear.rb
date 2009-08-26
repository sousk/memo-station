class ArticlesAccessCountClear < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.connection.execute("update articles set access_count = 5 where access_count > 5")
  end

  def self.down
    raise IrreversibleMigration
  end
end
