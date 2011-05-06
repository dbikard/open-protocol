class CreateProtocolVotes < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE protocol_votes (
        id                 INT(11) NOT NULL AUTO_INCREMENT,
        user_id            INT(11) NOT NULL,
        protocol_id        INT(11) NOT NULL,
        up                 TINYINT(1) NOT NULL,
        created_at         DATETIME,
        updated_at         DATETIME,
        PRIMARY KEY(id),
        UNIQUE INDEX uq_user_id_protocol_id_up_protocol_votes (user_id, protocol_id, up)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
    execute(%{
      ALTER TABLE protocols
        ADD COLUMN up_votes INT(11) DEFAULT 0,
        ADD COLUMN down_votes INT(11) DEFAULT 0
    })
  end

  def self.down
  end
end
