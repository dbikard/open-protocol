class CreateComments < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE comments (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        protocol_id   INT(11) NOT NULL,
        user_id       INT(11) NOT NULL,
        body          TEXT NOT NULL,
        created_at    DATETIME,
        updated_at    DATETIME,
        PRIMARY KEY(id),
        INDEX ix_protocol_id_comments (protocol_id),
        INDEX ix_user_id_comments (user_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
