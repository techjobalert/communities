class OrdersController < ApplicationController
  before_filter :authenticate_user!, :except => :payment_notifications
  load_and_authorize_resource

  def create
    @order = current_user.orders.build()
    @order.save
  end

  def create_transaction

    @order = current_user.orders.find_by_id(params[:order][:id])
    if @order.present?
      @order.ip_address = request.remote_ip
      item = Item.find(params[:order][:item_id])
      @order.item_id = item.id
      if @order.save
        @notice = purchase(@order, item, params[:pay_account])
      else
        @notice = {:type => "error", :message => "error"}
      end
    else
      @notice = {:type => "error", :message => "error"}
    end
    render :action => "response"
  end

  def card_verification
    result = validate_card(params[:pay_account])
    if result.blank?
      notice = {:type => "notice", :message => "Your card is valid"}
    else
      notice = {:type => "error", :message => result.join(". ")}
    end

    render :json => notice
  end

  private

    def purchase(order, item, account)
      if account
        response = GATEWAY.purchase(price_in_cents(item), credit_card(account), purchase_options(account, order))
        transaction = order.transactions.create!(
          :action => "purchase",
          :amount => price_in_cents(item),
          :response => response,
          :seller_id => item.user_id,
          :buyer_id => order.user_id)

        if response.success?
          transaction.pay
          notice = {:type => "notice", :message => "You have successfully bought the item"}
        else
          transaction.cancel
          notice = {:type => "error", :message => response.message}
        end


      else
        notice = {:type => "error", :message => "error"}
      end
    end

    def price_in_cents(item)
      (item.price * 100).round
    end

    def purchase_options(account, order) {
        :ip => request.remote_ip,
        :billing_address => {
          :name => [account[:first_name], account[:last_name]].join(" "),
          :address1 => account[:address1],
          :address2 => account[:address1],
          :city => account[:city],
          :state => account[:state],
          :country => account[:country],
          :zip => account[:zipcode],
          :phone => account[:phone]
        },
        :order_id => order.id
      }
    end

    def validate_card(account)
      unless credit_card(account).valid?
        @credit_card.errors.full_messages
      end
    end

    def credit_card(account)
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
        :type               => account[:payment_type],
        :number             => account[:number],
        :verification_value => account[:verification_value],
        :month              => account[:month],
        :year               => account[:year],
        :first_name         => account[:first_name],
        :last_name          => account[:last_name]
      )
    end

end
