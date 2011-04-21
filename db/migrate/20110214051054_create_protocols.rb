class CreateProtocols < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE protocols (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        name          VARCHAR(255) NOT NULL,
        introduction  TEXT NOT NULL,
        total_hours   INT(11) DEFAULT NULL,
        total_minutes INT(11) DEFAULT NULL,
        bench_hours   INT(11) DEFAULT NULL,
        bench_minutes INT(11) DEFAULT NULL,
        category_id   INT(11) DEFAULT NULL,
        user_id       INT(11) NOT NULL,
        created_at    DATETIME,
        updated_at    DATETIME,
        PRIMARY KEY(id),
        INDEX ix_protocols_user_id_category_id (user_id,category_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
