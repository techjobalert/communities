#encoding:utf-8
class NotifyMailer < ActionMailer::Base
  default from: "from@example.com"

  def notify_now(notify_summary)
    @notify_summary = notify_summary
    mail(:to => @notify_summary.email, :subject => "Changes in orthodontics360")
  end
end
