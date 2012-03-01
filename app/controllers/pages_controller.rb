class PagesController < ApplicationController

  layout :determine_layout, :except => [:home, :sign_in]

  def determine_layout
    if params[:action] == 'admin'
      "administrator"
    else
      "inner"
    end
  end



  def home
  end

  def sign_in
  end

  def item
  end

  def interesting_item
  end

  def items_you_follow
  end

  def account
  end

  def account_purchased_item
  end

  def user
  end

  def settings
  end

  def colleagues
  end

  def upload
  end

  def admin
  end
end
