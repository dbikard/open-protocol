class ProtocolVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :protocol
end