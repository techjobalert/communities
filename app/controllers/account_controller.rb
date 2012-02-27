class AccountController < ApplicationController
  def items
    @items = current_user.items.page(params[:page]).per(3)
    @notice = params[:notice]

    Rails.logger.info "============ #{params}"
  end

  def purchase
  end

  def purchased_items
  end

  def payments_info
  end
end
