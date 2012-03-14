class AccountController < ApplicationController
  authorize_resource :class => false

  def items
    @items  = current_user.items.published.page(params[:page]).per(3)
    @notice = params[:notice]
  end

  def purchase
  end

  def purchased_items
  end

  def payments_info
  end

  def check_card

  end

end
