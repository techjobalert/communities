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
end
