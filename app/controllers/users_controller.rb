class UsersController < ApplicationController
  before_filter :get_user, :except => [:upload_avatar]
  
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

  def upload_avatar
    @user = current_user

    @user.avatar = params[:file]
    @user.save!

    respond_to do |format|
      @data = { 
        :thumb_60 => @user.avatar_url(:thumb_60), 
        :thumb_70 => @user.avatar_url(:thumb_70), 
        :thumb_143 => @user.avatar_url(:thumb_143),
      }
      
      format.json { render json: @data.to_json }      
    end     
    
  end

  protected

  def get_user
    @user = User.find(params[:id])
  end
    
end
