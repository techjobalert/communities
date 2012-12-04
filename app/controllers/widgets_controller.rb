class WidgetsController < ApplicationController
  def index
  end

  def communities
    # @community_names = ["Orthodontics", "Implants"]
    # @communities = []

    # @community_names.map do |name| 
    #   name_down = name.downcase
    #   OpenStruct.new(name: name, icon: name_down, slug: name_down) 
    # end

    @communities = Community.all

  end
end



