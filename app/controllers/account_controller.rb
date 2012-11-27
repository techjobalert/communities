class AccountController < ApplicationController
  authorize_resource :class => false

  def items
    @items  = current_user.items
      .published
      .page(params[:page]).per(30)
  end

  def purchase

    items = current_user.orders
      .includes(:item)
      .select{ |o| o.state == 'paid' || o.state == 'closed' }
      .map{ |o| o.item if o.item.present? and o.item.state == 'published' }

    @items = Kaminari.paginate_array(items).page(params[:page]).per(30)

  end

  def purchased_items
    @items = current_user.items
      .purchased
      .page(params[:page]).per(30)

  end

  def get_contacts
    if current_user.social_account_credential
      if current_user.social_account_credential.updated_at < Time.zone.now - 1.hour
        current_user.refresh_gmail_token
      end
      @gmail_contacts = current_user.gmail_contacts
    else
      @notice = {:type => 'error', :message => "You do not have the authority to obtain contacts" }
      render :partial => "layouts/notice", :locals => {:notice => @notice}
    end
  end

  def payments_info
    @transactions = OrderTransaction.by_user current_user
    if current_user.role? "doctor"
      incoming_sum = OrderTransaction.incoming current_user

      @incoming_sum = incoming_sum.first.paid_to_seller.to_f / 100
    end
  end

  def check_card

  end

end
