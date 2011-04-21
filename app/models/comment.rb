class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :protocol
  validates :user, :presence => true
  validates :protocol, :presence => true
  validates :body, :presence => true
  attr_accessible :body, :user
end