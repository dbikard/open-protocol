class Author < ActiveRecord::Base
  attr_accessible :name
  belongs_to :protocol
  validates :name, :presence => true, :length => { :maximum => 255 }
end