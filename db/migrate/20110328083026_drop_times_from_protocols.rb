class DropTimesFromProtocols < ActiveRecord::Migration
  def self.up
    execute(%{
      ALTER TABLE protocols
        DROP COLUMN total_hours,
        DROP COLUMN total_minutes,
        DROP COLUMN bench_hours,
        DROP COLUMN bench_minutes
    })
  end

  def self.down
  end
end
