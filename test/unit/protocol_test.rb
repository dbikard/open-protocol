require 'test_helper'
class ProtocolTest < ActiveSupport::TestCase
  test "vote! should increment the internal counter" do
    protocol = Factory(:protocol)
    protocol.vote!(:up, Factory(:user))
    protocol.reload
    assert_equal protocol.up_votes, 1
    assert_equal protocol.down_votes, 0
  end
  test "vote! should create a new ProtocolVote the first time the user votes" do
    user     = Factory(:user)
    protocol = Factory(:protocol)
    protocol.vote!(:up, user)
    votes = protocol.protocol_votes
    assert_equal votes.size, 1
    assert_equal votes.first.user, user
    assert_equal votes.first.protocol, protocol
    assert votes.first.up?
  end
  test "vote! should not create a new ProtocolVote after the first time the user votes" do
    user     = Factory(:user)
    protocol = Factory(:protocol)
    protocol.vote!(:up, user)
    assert_no_difference('ProtocolVote.count') do
      protocol.vote!(:up, user)
    end
  end
  test "vote! should change a user's ProtocolVote" do
    user     = Factory(:user)
    protocol = Factory(:protocol)
    protocol.vote!(:up, user)
    vote = protocol.protocol_votes.first
    assert vote.up?
    protocol.vote!(:down, user)
    vote.reload
    assert !vote.up?
  end
  test "vote! should change a user's vote counter" do
    user     = Factory(:user)
    protocol = Factory(:protocol)
    protocol.vote!(:up, user)
    protocol.reload
    assert_equal protocol.up_votes, 1
    assert_equal protocol.down_votes, 0
    protocol.vote!(:down, user)
    protocol.reload
    assert_equal protocol.up_votes, 0
    assert_equal protocol.down_votes, 1
  end
  test "vote! should allow multiple users to vote" do
    user     = Factory(:user)
    user2    = Factory(:user)
    protocol = Factory(:protocol)
    protocol.vote!(:up, user)
    protocol.vote!(:up, user2)
    protocol.reload
    assert_equal protocol.up_votes, 2
    assert_equal protocol.down_votes, 0
    assert_equal protocol.protocol_votes.size, 2
  end
end