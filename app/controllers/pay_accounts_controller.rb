class PayAccountsController < ApplicationController
  def create
    params[:pay_account]['user_id'] = current_user.id
    @pay_account = PayAccount.new(params[:pay_account]) 
    
    if @pay_account.save
      @notice = {:type => "notice", :message => "successfull"}        
    else
      @notice = {:type => "error", :message => "error"}
    end    
  end

  def update
    @pay_account = PayAccount.new(params[:pay_account])
    
    if @pay_account.update_attributes params[:pay_account]
      @notice = {:type => "notice", :message => "successfull"}        
    else
      @notice = {:type => "error", :message => "error"}
    end
  end
end
