class ModeratorController < ApplicationController
  layout "administrator"

  def index
    @items = Item.unpublished.page(params[:page]).per(3)
  end

  def show 
    @item = Item.find params[:id]
  end
end
