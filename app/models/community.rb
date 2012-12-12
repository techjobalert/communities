class Community < ActiveRecord::Base
  attr_accessible :icon, :name
  has_and_belongs_to_many :users
  #has_and_belongs_to_many :items
  has_many :community_items
  has_many :items, through: :community_items

  extend FriendlyId
  friendly_id :name, use: :slugged
end
