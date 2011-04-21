class CreateCollectionAdmins < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE collection_admins (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        collection_id INT(11) NOT NULL,
        user_id       INT(11) NOT NULL,
        created_at    DATETIME,
        PRIMARY KEY(id),
        UNIQUE INDEX uq_collection_admins_collection_id_user_id (collection_id, user_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
