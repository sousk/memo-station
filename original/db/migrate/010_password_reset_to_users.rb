class PasswordResetToUsers < ActiveRecord::Migration
  def self.up
    User.transaction {
      User.find(:all).each{|user|
        user.password = user.loginname
        user.password_confirmation = user.password
        user.save!
      }
    }
  end

  def self.down
    raise IrreversibleMigration
  end
end
