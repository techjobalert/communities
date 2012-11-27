class CreateInvites
  @queue = :notifications_queue

  def self.perform(user_id,invites)
    user = User.find(user_id)


    NotifyMailer.send_email_message(message_id).deliver
  end
end