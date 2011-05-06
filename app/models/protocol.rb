class Protocol < ActiveRecord::Base
  attr_accessible :name, :introduction
  belongs_to :user
  has_many :authors, :dependent => :delete_all
  has_many :reagents
  has_many :steps, :order => "position asc"
  has_many :comments
  has_many :protocol_votes

  define_index do
    indexes :name
    indexes :up_votes, :sortable => true
    indexes :down_votes, :sortable => true
  end

  #
  # Sets a user's vote on the protocol. This has two components: the counters
  # on this object, and the rows in protocol_votes, which disallow double-voting.
  #
  # vote_type can either be :up or :down.
  #
  def vote!(vote_type, user)
    Protocol.transaction do
      new_vote, vote_changed = update_vote(vote_type, user)
      tick_vote_counter(vote_type, new_vote) if vote_changed
    end
  end

  def introduction=(text)
    write_attribute(:introduction, Sanitize.clean(text, SANITIZE_OPTIONS))
  end

  #
  # Sums the durations of the steps and returns it as a hours-minutes-seconds
  # array.
  #
  def total_time_components
    times_hash = self.steps.each_with_object({
      :hours => 0,
      :minutes => 0,
      :seconds => 0
    }) do |step, memo|
      memo[:hours] += step.duration_hours.to_i
      memo[:minutes] += step.duration_minutes.to_i
      memo[:seconds] += step.duration_seconds.to_i
    end
    times_hash[:minutes] += times_hash[:seconds] / 60
    times_hash[:seconds] = times_hash[:seconds] % 60
    times_hash[:hours] += times_hash[:minutes] / 60
    times_hash[:minutes] = times_hash[:minutes] % 60
    [times_hash[:hours], times_hash[:minutes], times_hash[:seconds]]
  end

  private

    #
    # Updates/creates the ProtocolVote for the user.
    #
    # Returns whether it was a new vote (which can be determined safely thanks to
    # the unique index on protocol_votes) and whether the vote was changed. Note
    # that vote_changed is true when we have a new vote, since null => true/false
    # is still a change.
    #
    def update_vote(vote_type, user)
      vote              = self.protocol_votes.where(:user_id => user.id).first
      is_upvote         = (vote_type == :up)
      current_is_upvote = vote.try(:up?)

      new_vote     = !vote
      vote_changed = new_vote || ((is_upvote && !current_is_upvote) || (!is_upvote && current_is_upvote))

      if new_vote
        vote = self.protocol_votes.build
        vote.user = user
      end

      vote.up = is_upvote
      vote.save!
      return new_vote, vote_changed
    end

    #
    # Increments/decrements the vote counters on this model. If it's a new vote
    # it does not maintain the invariant that you may only have one vote per user
    # per protocol. (And it can only be in one direction at a time.) i.e. vote
    # changes will increment one counter and decrement the other, new votes will
    # increment/decrement one counter but won't touch the other.
    #
    # This is implemented as raw SQL so we can get the database to do atomic
    # increment/decrement.
    #
    def tick_vote_counter(vote_type, new_vote)
      sql = case vote_type
        when :up
          %{UPDATE protocols SET up_votes = up_votes + 1} +
          (new_vote ? "" : ", down_votes = down_votes - 1")
        when :down
          %{UPDATE protocols SET down_votes = down_votes + 1} +
          (new_vote ? "" : ", up_votes = up_votes - 1")
      end
      sql += %{ WHERE id = #{self.id}}
      self.class.connection.update(sql)
    end
end