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
    @transactions = OrderTransaction.by_user current_user
    if current_user.role? "doctor"
      icoming_sum = OrderTransaction.select("SUM(paid_to_seller) as paid_to_seller")
        .where("state = ? AND seller_id = ?", "closed", current_user.id)

      @icoming_sum = icoming_sum.first.paid_to_seller.to_f / 100
    end
  end

  def check_card

  end

end
