class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  fires :new_follow,  :on                 => [:create, :destroy],
                      :actor              => :follower,
                      #implicit :subject  => self,
                      :secondary_subject  => 'followable',
                      :if => lambda { |followable| 
                      	followable_type.in %w(Item Comment) and followable.published != false 
                       }

  def block!
    self.update_attribute(:blocked, true)
  end

end
