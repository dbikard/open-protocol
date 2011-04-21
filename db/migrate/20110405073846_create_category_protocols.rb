class CreateCategoryProtocols < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE category_protocols (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        category_id   INT(11) DEFAULT NULL,
        protocol_id   INT(11) NOT NULL,
        created_at    DATETIME,
        PRIMARY KEY(id),
        UNIQUE INDEX uq_category_protocols_category_id_protocol_id (category_id,protocol_id),
        INDEX ix_category_protocols_protocol_id (protocol_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
