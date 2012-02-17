class TimelineEvent < ActiveRecord::Base
  belongs_to :actor,              :polymorphic => true
  belongs_to :subject,            :polymorphic => true
  belongs_to :secondary_subject,  :polymorphic => true

  after_create :after_create_handler

  def after_create_handler
	  Resque.enqueue(NotifyNow, id)
  end
end

