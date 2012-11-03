class SendProcessedMessage
  @queue = :store_asset_notifications_queue

  def self.perform(item_id)
    NotifyMailer.send_processed_email_message(item_id).deliver
  end

end