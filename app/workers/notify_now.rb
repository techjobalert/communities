class NotifyNow
  @queue = :notifications_queue

  def self.perform(event_id)
  	event = TimelineEvent.find(event_id)
  	followers, owner = nil

  	if event.subject_type == "Comment"
  		commentable = event.subject.commentable
      if commentable.is_a? Item
        if commentable.user.commented_item == 1 or commentable.user.recommended_comment == 1
          owner = commentable.user
        end
      end
  	elsif event.subject_type == "Follow"
      followable = event.subject.followable
      if followable.is_a? User and followable.following_me == 1
        owner = event.subject.followable
      elsif followable.is_a? Item and followable.following_item == 1
        owner = event.subject.followable.user
      end
  	else
  		if defined? event.followers
        followers = event.followers
      else
        p event
      end
  	end

    if owner
      # If we have owner, we just notify only owner
      NotifyMailer.notify_now(event, owner).deliver
		else
      # Else notify all followers
      followers.each do |follower|
        NotifyMailer.notify_now(event, follower).deliver
      end
    end
  end

end