class CommunitiesController < ApplicationController
  #index all communities
  def index
    @communities = Community.all
  end
  
  def self.get_communities
    Community.all
  end

  def show
    slug = params[:id]
    @community = Community.find_by_slug(slug) 
    display_404 unless @community
  end

end
