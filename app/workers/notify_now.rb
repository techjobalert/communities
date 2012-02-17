class NotifyNow
  @queue = :notifications_queue

  def self.perform(event_id)
  	event = TimelineEvent.find(event_id)
  	followers = nil
  	
  	if event.subject_type == "Comment"
  		followers = event.subject.commentable.followers
  	else
  		followers = event.followers
  	end

		followers.each do |follower| 
      NotifyMailer.notify_now(event, follower.email).deliver
    end
  end
end