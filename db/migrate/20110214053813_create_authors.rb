class CreateAuthors < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE authors (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        name          VARCHAR(255) NOT NULL,
        protocol_id   INT(11) DEFAULT NULL,
        created_at    DATETIME,
        updated_at    DATETIME,
        PRIMARY KEY(id),
        INDEX ix_authors_protocol_id (protocol_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
