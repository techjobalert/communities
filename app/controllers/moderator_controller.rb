class ModeratorController < ApplicationController
  layout "administrator"

  before_filter :get_item, :only => [:item_show, :item_publish, :item_deny]

  def items
    @items = Item.state_is("moderated").page(params[:page]).per(3)
  end

  def item_show    
  end

  def item_publish
    @item.publish
    redirect_to moderator_path
  end

  def item_deny
    @item.deny
    redirect_to moderator_path
  end  

  protected

  def get_item
    @item = Item.find params[:id]
  end
end
