class Order < ActiveRecord::Base

  belongs_to :user
  has_many :transactions, :class_name => "OrderTransaction"
  belongs_to :item

  state_machine :state, :initial => :not_paid do
    after_transition :on => :pending do |order|
      order.update_attributes({:purchased_at => Time.now})
    end

    event :not_paid do
      transition :pending => :not_paid
    end

    event :pending do
      transition :not_paid => :pending
    end

    event :pay do
      transition :pending => :paid
    end

    event :cancel do
      transition [:pending, :not_paid] => :canceled
    end

  end
end