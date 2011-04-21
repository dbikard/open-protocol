class CreateImages < ActiveRecord::Migration
  def self.up
    execute(%{
      CREATE TABLE images (
        id                 INT(11) NOT NULL AUTO_INCREMENT,
        user_id            INT(11) NOT NULL,
        image_file_name    VARCHAR(255) DEFAULT NULL,
        image_content_type VARCHAR(255) DEFAULT NULL,
        image_file_size    INT(11) DEFAULT NULL,
        image_updated_at   DATETIME,
        created_at         DATETIME,
        updated_at         DATETIME,
        PRIMARY KEY(id)
      ) ENGINE=InnoDB CHARSET=UTF8
    })
  end

  def self.down
  end
end
