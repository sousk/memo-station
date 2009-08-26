class Createfoos < ActiveRecord::Migration
  def self.up
    create_table :bars do |t|
      t.column "body", :text
    end
  end

  def self.down
    drop_table :bars
  end
end
