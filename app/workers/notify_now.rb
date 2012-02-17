class NotifyNow
  @queue = :notifications_queue

  def self.perform(event)
    event.subject.followers.each do |follower| 
    	p follower
      NotifyMailer.notify_now(event, follower.email).deliver
    end
  end
end