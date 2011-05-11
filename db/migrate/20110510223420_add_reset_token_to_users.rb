class AddResetTokenToUsers < ActiveRecord::Migration
  def self.up
    execute(%{
      ALTER TABLE users ADD COLUMN reset_token VARCHAR(20) DEFAULT NULL
    })
  end

  def self.down
  end
end
