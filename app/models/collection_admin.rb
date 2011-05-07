class CollectionAdmin < ActiveRecord::Base
  belongs_to :administrated_collection, :foreign_key => :collection_id, :class_name => "Collection"
  belongs_to :admin, :foreign_key => :user_id, :class_name => "User"
end