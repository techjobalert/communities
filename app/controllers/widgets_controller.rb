class WidgetsController < ApplicationController
  def index
  end

  def communities
   @communities = Community.all
  end

end



