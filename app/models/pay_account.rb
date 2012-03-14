# encoding: utf-8
class PayAccount < ActiveRecord::Base
  belongs_to :user
  has_many   :orders

  attr_accessible :first_name, :last_name, :verification_value, :year, :month,
                  :number, :payment_type, :user_id, :active

  validates_format_of :first_name, :last_name, :with=> /\A[а-яА-Яa-zA-Z0-9_\.\-\s]+\Z/u,
                      :message => "Wrong name format"

  validates_presence_of     :verification_value, :country, :address1, :city, :state
  validates_numericality_of :number, :year, :month, :zipcode
  validates_length_of       :number, :is => 16, :message => "Wrong format."
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
  validates_format_of       :phone, :message => "Must be a valid telephone number.", :with => /^[\(\)0-9\- \+\.]{10,20}$/, :allow_blank => true
  validates_exclusion_of    :payment_type, :in => %w( visa mastercard discover ), :message => "card type %s is not allowed"

end
