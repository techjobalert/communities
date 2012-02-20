class NotifyNow
  @queue = :notifications_queue

  def self.perform(event_id)
  	event = TimelineEvent.find(event_id)
  	followers, owner = nil
  	
  	if event.subject_type == "Comment"
  		followers = event.subject.commentable.followers
  	elsif event.subject_type == "Follow"
      followable = event.subject.followable
      if followable.is_a? User
        owner = event.subject.followable
      elsif followable.is_a? Item
        owner = event.subject.followable.user
      end
  	else
  		followers = event.followers
  	end

    if owner
      # If we have owner, we just notify only owner
      NotifyMailer.notify_now(event, owner.email).deliver 
		else
      # Else notify all followers
      followers.each do |follower| 
        NotifyMailer.notify_now(event, follower.email).deliver
      end
    end
  end

end