class PayAccountsController < ApplicationController
  def create
    params[:pay_account]['user_id'] = current_user.id
    params[:pay_account]['active'] = true
    @pay_account = PayAccount.new(params[:pay_account])

    if @pay_account.save
      @notice = {:type => "notice", :message => "successfull"}
    else
      @notice = {:type => "error", :message => @pay_account.errors.full_messages.first
      }
    end
  end

  def update
    @pay_account = current_user.pay_accounts.first

    if @pay_account.update_attributes params[:pay_account]
      @notice = {:type => "notice", :message => "successfull"}
    else
      @notice = {:type => "error", :message => "error"}
    end
  end
end
