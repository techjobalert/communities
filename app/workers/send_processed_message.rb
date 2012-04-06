class SendProcessedMessage
  @queue = :notifications_queue

  def self.perform(attachment_id)
    NotifyMailer.send_processed_email_message(attachment_id).deliver
  end

end