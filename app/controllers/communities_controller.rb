class CommunitiesController < ApplicationController

  before_filter :init_communities
  
  def index
    
  end
  
  def show
    slug = params[:id]
    @community = Community.find_by_slug(slug) 
    session[:community_id] = @community.id if user_signed_into_community @community
  end

  private

  def init_communities
    @communities = Community.all
  end

  def user_signed_into_community community
    user_signed_in? && (@community.include? current_user)
  end
end
