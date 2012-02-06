class PagesController < ApplicationController
  layout "inner", :except => [:home, :sign_in]

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
end
