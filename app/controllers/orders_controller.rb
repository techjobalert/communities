class OrdersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    params[:order][:user_id] = current_user.id
    @order = current_user.orders.build(params[:order])
    @order.ip_address = request.remote_ip
    if @order.save
      if purchase(@order, params[:pay_account])
        render :action => "success"
      else
        render :action => "failure"
      end
    else
      render :action => 'new'
    end
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

    def purchase(order, account)
      if account
        response = GATEWAY.purchase(price_in_cents, credit_card(account), purchase_options(account))
        order.transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
        if response.success?
          order.user.update_attribute(:purchased_at, Time.now)
        end
        response.success?
      else
        false
      end
    end

    def price_in_cents
      100
    end

    def purchase_options(account)
      {
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
        }
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
