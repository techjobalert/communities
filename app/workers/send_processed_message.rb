class SendProcessedMessage
  @queue = :store_asset_notifications_queue

  def self.perform(item_id)
  	Rails.logger.debug "_____2______#{item_id}____________"
    NotifyMailer.send_processed_email_message(item_id).deliver
  end

end