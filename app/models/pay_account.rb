class PayAccount < ActiveRecord::Base
  belongs_to :user
  has_many   :orders

  attr_accessible :first_name, :last_name, :verification_value, :year, :month,
    :number, :payment_type, :user_id, :active

  validate :validate_card

  def check_card
    validate_card
  end

  private

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add_to_base message
      end
    end
  end

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
      :type       => 'visa',
      :number     => '4222222222222',
      :month      => '10',
      :year       => '2013',
      :first_name => 'Bob',
      :last_name  => 'Smith',
      :verification_value  => '111' )
  end
end