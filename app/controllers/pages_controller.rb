class PagesController < ApplicationController
  layout "inner", :except => :home

  def home
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
end
