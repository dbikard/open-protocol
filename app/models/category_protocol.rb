class CategoryProtocol < ActiveRecord::Base
  belongs_to :category
  belongs_to :protocol
end