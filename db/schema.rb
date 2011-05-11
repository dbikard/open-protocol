# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110510223420) do

  create_table "authors", :force => true do |t|
    t.string   "name",        :null => false
    t.integer  "protocol_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["protocol_id"], :name => "ix_authors_protocol_id"

  create_table "categories", :force => true do |t|
    t.string   "name",          :null => false
    t.integer  "collection_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["collection_id"], :name => "ix_categories_collection_id"

  create_table "category_protocols", :force => true do |t|
    t.integer  "category_id"
    t.integer  "protocol_id", :null => false
    t.datetime "created_at"
  end

  add_index "category_protocols", ["category_id"], :name => "ix_category_protocols_category_id"
  add_index "category_protocols", ["protocol_id"], :name => "ix_category_protocols_protocol_id"

  create_table "collection_admins", :force => true do |t|
    t.integer  "collection_id", :null => false
    t.integer  "user_id",       :null => false
    t.datetime "created_at"
  end

  add_index "collection_admins", ["collection_id", "user_id"], :name => "uq_collection_admins_collection_id_user_id", :unique => true

  create_table "collections", :force => true do |t|
    t.string   "name",                        :null => false
    t.string   "contact",     :limit => 1000
    t.string   "homepage",    :limit => 1000
    t.text     "description"
    t.integer  "user_id",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collections", ["user_id"], :name => "ix_collections_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "protocol_id", :null => false
    t.integer  "user_id",     :null => false
    t.text     "body",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["protocol_id"], :name => "ix_protocol_id_comments"
  add_index "comments", ["user_id"], :name => "ix_user_id_comments"

  create_table "images", :force => true do |t|
    t.integer  "user_id",            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "protocol_votes", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "protocol_id", :null => false
    t.boolean  "up",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "protocol_votes", ["user_id", "protocol_id", "up"], :name => "uq_user_id_protocol_id_up_protocol_votes"

  create_table "protocols", :force => true do |t|
    t.string   "name",                        :null => false
    t.text     "introduction",                :null => false
    t.integer  "category_id"
    t.integer  "user_id",                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "up_votes",     :default => 0
    t.integer  "down_votes",   :default => 0
  end

  add_index "protocols", ["user_id", "category_id"], :name => "ix_protocols_user_id_category_id"

  create_table "reagents", :force => true do |t|
    t.string   "name",                          :null => false
    t.integer  "protocol_id"
    t.string   "external_link", :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reagents", ["protocol_id"], :name => "ix_reagents_protocol_id"

  create_table "steps", :force => true do |t|
    t.string   "name",             :null => false
    t.text     "instructions",     :null => false
    t.integer  "duration_hours"
    t.integer  "duration_minutes"
    t.integer  "duration_seconds"
    t.integer  "position",         :null => false
    t.integer  "protocol_id",      :null => false
    t.integer  "image_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "steps", ["protocol_id", "position"], :name => "uq_steps_protocol_id_position", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name",                                             :null => false
    t.string   "email",                                            :null => false
    t.string   "crypted_password",                                 :null => false
    t.string   "password_salt",                                    :null => false
    t.string   "persistence_token",                                :null => false
    t.string   "single_access_token",                              :null => false
    t.string   "perishable_token",                                 :null => false
    t.integer  "login_count",                       :default => 0, :null => false
    t.integer  "failed_login_count",                :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_token",         :limit => 20
  end

end
