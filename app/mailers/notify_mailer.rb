#encoding:utf-8
class NotifyMailer < ActionMailer::Base
  default from: "from@example.com"

  def notify_now(notify, owner)
    @notify, @owner = notify, owner
    mail(:to => owner.email, :subject => "Changes in orthodontics360")
  end

  def send_email_message(message_id)
  	@message = Message.find(message_id)
  	@from_user = @message.user
  	@to_user = @message.receiver
  	@message_text = @message.body
  	mail(:to => @to_user.email, :subject => "[orthodontics360] Direct message from #{@from_user.full_name}")
  end
end
