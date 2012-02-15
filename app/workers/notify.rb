class NotifyNow
  @queue = :notifications_queue

  def self.perform(user_id, event_subject_type, event_subject_id, event_type, event_id)
    event_subject_type = event_subject_type.to_sym
    event_type = event_type.to_sym
    user = User.find(user_id)
    if user.notify_when == "always"
      notify_summary = NotifySummary.new(user)
      if ((event_subject_type == :challenges) && user.notify_challenges) ||
              ((event_subject_type == :ideas) && user.notify_ideas)
      then
        notify_summary.add_event(event_subject_type, event_subject_id, event_type, event_id)
        NotifyMailer.notify_now(notify_summary).deliver
      end
    end
    if event_subject_type == :challenges && event_type == :comments
      #todo: get the comment thread owners and send them notifications
    end
    if event_subject_type == :ideas && event_type == :comments
      #todo: get the comment thread owners and send them notifications
    end
  end
end