class CreateCollections < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE collections (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        name          VARCHAR(255) NOT NULL,
        contact       VARCHAR(1000) DEFAULT NULL,
        homepage      VARCHAR(1000) DEFAULT NULL,
        description   TEXT DEFAULT NULL,
        user_id       INT(11) NOT NULL,
        created_at    DATETIME,
        updated_at    DATETIME,
        PRIMARY KEY(id),
        INDEX ix_collections_user_id (user_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
