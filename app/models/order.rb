class Order < ActiveRecord::Base
  belongs_to :user
  has_many :transactions, :class_name => "OrderTransaction"
  belongs_to :item
end