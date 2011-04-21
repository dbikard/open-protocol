class CreateSteps < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE steps (
        id                 INT(11) NOT NULL AUTO_INCREMENT,
        name               VARCHAR(255) NOT NULL,
        instructions       TEXT NOT NULL,
        duration_hours     INT(11) DEFAULT NULL,
        duration_minutes   INT(11) DEFAULT NULL,
        duration_seconds   INT(11) DEFAULT NULL,
        position           INT(11) NOT NULL,
        protocol_id        INT(11) NOT NULL,
        image_id           INT(11) DEFAULT NULL,
        created_at         DATETIME,
        updated_at         DATETIME,
        PRIMARY KEY(id),
        UNIQUE INDEX uq_steps_protocol_id_position (protocol_id,position)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
