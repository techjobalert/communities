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

  def send_invite(from_user,reciever_name,receiver_email)
    @from_user = from_user
    @reciever_name = reciever_name
    mail(:to => receiver_email, :subject => "[orthodontics360] Direct message from #{from_user.full_name}")
  end

  def send_moderation_email_message(message_id)
    @message = Message.find(message_id)
    @to_user = @message.receiver
    # @item_title = @message.title
    # @item_id = @message.object_id
    @item = Item.find(@message.object_id)
    @message_text = @message.body
    mail(:to => @to_user.email, :subject => "[orthodontics360] Direct message from moderator")
  end

  def send_processed_email_message(item_id)
    @item = Item.find(item_id)
    @file_name = File.basename(@item.attachments.where(:file_processing => nil).last.file.path)
    if @item and @file_name
      mail(
        :to => @item.user.email,
        :subject => "[orthodontics360] Your attachment file #{@file_name} processed"
      )
    end
  end
end
