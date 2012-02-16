class HomeController < ApplicationController
  def index
    @items = Item.published.page params[:page]
  end
end
