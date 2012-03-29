class HomeController < ApplicationController
  def index
    @items = Item.state_is("published").order("created_at DESC").page params[:page]
  end

  def new_captcha
  end

  def orthodontic_sale

  end

end