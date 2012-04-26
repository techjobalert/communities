class AccountController < ApplicationController
  authorize_resource :class => false

  def items
    @items  = current_user.items
      .published
      .page(params[:page]).per(3)
  end

  def purchase

    items = current_user.orders
      .includes(:item)
      .select{ |o| o.state == 'paid' || o.state == 'closed' }
      .map{ |o| o.item if o.item.present? and o.item.state == 'published' }

    @items = Kaminari.paginate_array(items).page(params[:page]).per(3)

  end

  def purchased_items
    @items = current_user.items
      .purchased
      .page(params[:page]).per(3)

  end

  def payments_info
    @transactions = OrderTransaction.by_user current_user
    if current_user.role? "doctor"
      icoming_sum = OrderTransaction.incoming current_user

      @icoming_sum = icoming_sum.first.paid_to_seller.to_f / 100
    end
  end

  def check_card

  end

end
