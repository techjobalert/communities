class CommunitiesController < ApplicationController

  before_filter :init_communities
  
  def index
    
  end
  
  def show
    slug = params[:id]
    @community = Community.find_by_slug(slug) 
    #redirect to suggest_community
  end

  private

  def init_communities
    @communities = Community.all
  end


end
