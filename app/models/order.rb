class Order < ActiveRecord::Base
  belongs_to :user
  belongs_to :pay_account
  has_many :transactions, :class_name => "OrderTransaction"

  attr_accessor :card_number, :card_verification
  validate  :validate_card

  def purchase
    pay_account = user.pay_accounts.where(:active=>true).first
    if pay_account
      pay_account_id = pay_account.id
      response = GATEWAY.purchase(price_in_cents, credit_card(pay_account), purchase_options(pay_account))
      transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
      if response.success?
        update_attribute(:pay_account_id, pay_account.id)
        user.update_attribute(:purchased_at, Time.now)
      end
      response.success?
    else
      false
    end
  end

  def price_in_cents
    (cart.total_price*100).round
  end

  private

  def purchase_options(account)
    {
      :ip => ip_address,
      :billing_address => {
        :name => [account.first_name, account.last_name].join(" "),
        :address1 => account.address1,
        :address2 => account.address1,
        :city => account.city,
        :state => account.state,
        :country => account.country,
        :zip => account.zipcode,
        :phone => account.phone
      }
    }
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

  def credit_card(account)
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => account.payment_type,
      :number             => account.number,
      :verification_value => account.verification_value,
      :month              => account.month,
      :year               => account.year,
      :first_name         => account.first_name,
      :last_name          => account.last_name
    )
  end
end