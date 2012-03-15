class NotifyNow
  @queue = :notifications_queue

  def self.perform(event_id)
  	event = TimelineEvent.find(event_id)
  	receivers = []
    subjects_list = %w(Comment Follow Item Contribution)

  	if event.subject_type == "Comment"
  		commentable = event.subject.commentable
      if commentable.is_a? Item
        if event.event_type != "liked_comment" and commentable.user.commented_item == "1"
          receivers << commentable.user
        end
        if event.event_type == "liked_comment" and commentable.user.recommended_comment == "1"
          receivers <<  event.subject.user
        end
      end
    end
  	if event.subject_type == "Follow"
      followable = event.subject.followable
      if followable.is_a? User and followable.following_me == "1"
        receivers << followable
      elsif followable.is_a? Item and followable.user.following_item == "1"
        receivers << followable.user
      end
    end
    if event.subject_type == "Item"
      item = event.subject
      if item.state == "published"
        receivers << event.subject.followers.select{|f| f.following_published == "1"}
        receivers << event.subject.user.followers.select{|f| f.following_published == "1"}
      end
    end
    if event.subject_type == "Contribution"
      if event.actor.added_as_author == "1"
        receivers << event.actor
      end
    end
  	if not event.subject_type.in? subjects_list
  		if defined? event.subject.followers
        receivers << event.subject.followers
      else
        p event
      end
  	end

		if receivers
      receivers.flatten.uniq.each do |receiver|
        NotifyMailer.notify_now(event, receiver).deliver
      end
    end
  end

end