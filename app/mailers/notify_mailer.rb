#encoding:utf-8
class NotifyMailer < ActionMailer::Base
  default from: "from@example.com"

  def notify_now(notify, email)
    @notify = notify
    mail(:to => email, :subject => "Changes in orthodontics360")
  end
end
