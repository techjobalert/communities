class CommunityItem < ActiveRecord::Base
  belongs_to :community
  belongs_to :item
  # attr_accessible :title, :body
end
