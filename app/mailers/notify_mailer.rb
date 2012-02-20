#encoding:utf-8
class NotifyMailer < ActionMailer::Base
  default from: "from@example.com"

  def notify_now(notify, owner)
    @notify, @owner = notify, owner
    mail(:to => owner.email, :subject => "Changes in orthodontics360")
  end
end
