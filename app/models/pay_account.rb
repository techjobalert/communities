class PayAccount < ActiveRecord::Base
  belongs_to :user

  attr_accessible :first_name, :last_name, :verification_value, :year, :month, 
    :number, :payment_type, :user_id, :active
end
