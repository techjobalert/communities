class CreateInvites
  @queue = :notifications_queue

  def self.perform(user_id,invites)
    user = User.find(user_id)
    invites.each do |invite|
      if invite[:email].present?
        NotifyMailer.send_invite(user,invite[:name],invite[:email])
      end
    end
  end
end