class NotifyNow
  @queue = :notifications_queue

  def self.perform(event_id)
  	event = TimelineEvent.find(event_id)
  	followers, owner = [], nil

  	if event.subject_type == "Comment"
  		commentable = event.subject.commentable
      if commentable.is_a? Item
        if commentable.user.commented_item == "1" or commentable.user.recommended_comment == "1"
          owner = commentable.user
        end
      end
  	elsif event.subject_type == "Follow"
      followable = event.subject.followable
      if followable.is_a? User and followable.following_me == "1"
        owner = followable
      elsif followable.is_a? Item and followable.user.following_item == "1"
        owner = followable.user
      end
    elsif event.subject_type == "Item"
      item = event.subject
      if item.state == "published"
        followers << event.subject.followers
        followers << event.subject.user.followers
      end
  	else
  		if defined? event.subject.followers
        followers << event.subject.followers
      else
        p event
      end
  	end

    if owner
      # If we have owner, we just notify only owner
      NotifyMailer.notify_now(event, owner).deliver
    end
		if followers
      # Else notify all followers
      followers.flatten.each do |follower|
        NotifyMailer.notify_now(event, follower).deliver
      end
    end
  end

end