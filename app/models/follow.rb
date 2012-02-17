class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  fires :follow,    :on                 => :create,
                    :actor              => :follower,
                    :secondary_subject  => 'followable'

  # fires :unfollow,  :on                 => :destroy,
  #                   :actor              => :follower,
  #                   :secondary_subject  => 'followable'

  def block!
    self.update_attribute(:blocked, true)
  end

end
