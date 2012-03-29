class OrderTransaction < ActiveRecord::Base

  belongs_to :order
  serialize :params

  state_machine :state, :initial => :pending do
    after_transition :on => :pay do |t|
      t.order.pay
      item = t.order.item
      item.amount += item.price
      item.save!
    end

    after_transition :on => :cancel do |t|
      t.order.cancel
    end

    event :pay do
      transition :pending => :paid
    end

    event :cancel do
      transition :pending => :canceled
    end

    event :close do
      transition :paid => :closed
    end

  end

  def response=(response)
    self.success       = response.success?
    self.authorization = response.authorization
    self.message       = response.message
    self.params        = response.params
    rescue ActiveMerchant::ActiveMerchantError => e
    self.success       = false
    self.authorization = nil
    self.message       = e.message
    self.params        = {}
  end

  def self.by_user user
    find_by_sql "SELECT * FROM order_transactions
      WHERE
        ( buyer_id = #{user.id} AND ( state = 'paid' OR state = 'closed' ) )
        OR ( seller_id = #{user.id} AND state = 'closed' )
      ORDER BY updated_at DESC"
  end
end