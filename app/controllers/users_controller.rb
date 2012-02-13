class UsersController < ApplicationController

  def show    
  end
  
  def edit    
  end

  def update
    respond_to do |format|

      params[:user][:birthday] = Date.strptime(params[:user][:birthday], "%m/%d/%Y")

      if current_user.update_attributes params[:user]
        format.html { redirect_to edit_user_path(current_user), notice: "success" }
        format.json { head :ok }
      else
        format.html { redirect_to edit_user_path(current_user), notice: "error" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_avatar
    current_user.avatar = params[:file]
    current_user.save!

    respond_to do |format|
      @data = { 
        :thumb_60 => current_user.avatar_url(:thumb_60), 
        :thumb_70 => current_user.avatar_url(:thumb_70), 
        :thumb_143 => current_user.avatar_url(:thumb_143),
      }
      
      format.json { render json: @data.to_json }      
    end     
    
  end
end
