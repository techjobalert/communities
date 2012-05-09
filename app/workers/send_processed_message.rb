class SendProcessedMessage
  @queue = :store_asset_notifications_queue

  def self.perform(attachment_id, source_file_path)
    NotifyMailer.send_processed_email_message(attachment_id).deliver
    # delete source file
    FileUtils.remove_file source_file_path, :verbose => true
  end

end