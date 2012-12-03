class CommunitiesController < ApplicationController
  #index all communities
  def index
    @communities = Community.all
  end
  
  def self.get_communities
    Community.all
  end

  def show
    Rails.logger.info params
    slug = params[:id]
    @community = Community.find_by_slug(slug) #where(slug: slug).first
    display_404 unless @community

  end

end
