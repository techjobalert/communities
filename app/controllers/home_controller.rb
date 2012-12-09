class HomeController < ApplicationController
  def index
    # @content_type = ["video","article","presentation"].include?(params[:type]) ? params[:type] : "video"
    # @items = Item.state_is("published").content_type(@content_type).order("created_at DESC").page params[:page]
    @communities = Community.all
    Rails.logger.info "home_controller#index"
  end

  def new_captcha

  end

  def orthodontic_sale

  end

end