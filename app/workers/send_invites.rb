class SendInvites
  @queue = :notifications_queue

  def self.perform(user_id,invites)
    user = User.find(user_id)
    invites.each do |invite|
      if invite[:email].present?
        Rails.logger.info "----1-1-1-1-1-1-1---"
        NotifyMailer.send_invite(user,invite[:name],invite[:email]).deliver!
      end
    end
  end
end