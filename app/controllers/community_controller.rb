class CommunityController < ApplicationController
  #index all communities
  def index
    @communities = Community.all
    #respond_to do |format|
      
    #end
  end
  
  def self.get_communities
    Community.all
  end
end
