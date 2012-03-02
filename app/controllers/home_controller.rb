class HomeController < ApplicationController
  def index
    if params[:q].present?
      @items = ThinkingSphinx.search("#{params[:q]}", :classes => [Item])
        .page(params[:page]).per(3)
    else
      @items = Item.state_is("published").page(params[:page])
    end
  end

  def new_captcha
  end
end