class Community < ActiveRecord::Base
  attr_accessible :icon, :name
  has_and_belongs_to_many :users
  has_and_belongs_to_many :items

  extend FriendlyId
  friendly_id :name, use: :slugged
end
