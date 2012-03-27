class Order < ActiveRecord::Base

  belongs_to :user
  has_many :transactions, :class_name => "OrderTransaction"
  belongs_to :item

  state_machine :state, :initial => :not_paid do
    after_transition :on => :pay do |order|
      order.update_attributes({:purchased_at => Time.now})
    end

    event :pay do
      transition :not_paid => :paid
    end

    event :cancel do
      transition :not_paid => :canceled
    end

  end
end