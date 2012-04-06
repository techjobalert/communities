class SendMessage
  @queue = :notifications_queue

  def self.perform(message_id)
  	NotifyMailer.send_email_message(message_id).deliver
  end

end