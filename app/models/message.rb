class Message < ActiveRecord::Base
  belongs_to :user #,:counter_cache => true
  belongs_to :receiver, class_name: :User, inverse_of: :messages_received
end
