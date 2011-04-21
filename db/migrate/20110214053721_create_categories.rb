class CreateCategories < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE categories (
        id            INT(11) NOT NULL AUTO_INCREMENT,
        name          VARCHAR(255) NOT NULL,
        collection_id INT(11) NOT NULL,
        created_at    DATETIME,
        updated_at    DATETIME,
        PRIMARY KEY(id),
        INDEX ix_categories_collection_id (collection_id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
