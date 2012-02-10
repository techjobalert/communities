class UsersController < ApplicationController
  before_filter :get_user 
  
  def show    
  end
  
  def edit    
  end

  def update
    respond_to do |format|
      if @user.update_attributes params[:user]
        format.html { redirect_to edit_user_path(@user), notice: "success" }
        format.json { head :ok }
      else
        format.html { redirect_to edit_user_path(@user), notice: "error" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  protected
    def get_user
      @user = User.find(params[:id])
    end
    
end
