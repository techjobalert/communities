class ItemsController < InheritedResources::Base
  def index
    @items = Item.page params[:page]
  end  
end
