class OrdersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    params[:order][:user_id] = current_user.id
    @order = current_user.build_order(params[:order])
    @order.ip_address = request.remote_ip
    if @order.save
      if @order.purchase
        render :action => "success"
      else
        render :action => "failure"
      end
    else
      render :action => 'new'
    end
  end

end
