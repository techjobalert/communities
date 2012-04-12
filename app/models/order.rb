class Order < ActiveRecord::Base

  belongs_to :user
  has_many :transactions, :class_name => "OrderTransaction"
  belongs_to :item

  fires :updated_item,    :on     => :update,
                          :actor  => :user,
                          :subject => :user,
                          :secondary_subject => :self,
                          :if => lambda { |order| order.state == "paid" && order.purchased_at.present? }

  state_machine :state, :initial => :not_paid do
    after_transition :on => :pay do |order|
      order.update_attributes({ :purchased_at => Time.now })
    end

    event :pay do
      transition all => :paid
    end

    event :cancel do
      transition all => :canceled
    end

  end
end