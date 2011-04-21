class Category < ActiveRecord::Base
  attr_accessible :name
  has_many :category_protocols
  belongs_to :collection
  validates :name, :presence => true
end