class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]

  def index
    @users = User.all
  end  

  def show 
    @user = params[:id] == current_user.id ? current_user : User.find(params[:id])
  end
  
  def edit    
  end

  def update
    respond_to do |format|
      
      parse_settings(params)
      if params[:user][:birthday]
        params[:user][:birthday] = Date.strptime(params[:user][:birthday], "%m/%d/%Y")
      end
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
    respond_to do |format|
      if current_user.save
        @data = { 
          :thumb_60 => current_user.avatar_url(:thumb_60), 
          :thumb_70 => current_user.avatar_url(:thumb_70), 
          :thumb_143 => current_user.avatar_url(:thumb_143),
        }
        
        format.json { render json: @data.to_json }
      end
    end     
  end  
  

  def follow
    following_user_id = params[:user_id]
    @message = ""
    if following_user_id != current_user.id
      @following_user = User.find(following_user_id)
      current_user.follow(@following_user)
    else
      @message = "You cannot follow your self."
    end
  end

  def unfollow
    following_user_id = params[:user_id]
    @following_user = User.find(following_user_id)
    if current_user.following?(@following_user)
      current_user.stop_following(@following_user)
    else
      @message = "Some error."
    end
  end  

  private
  def parse_settings(params)
    _settings={}  
    params[:user].each do |key, value|
      if key =~ /^settings_(\w+)$/
        _settings[$1.to_sym] = value
      end
    end
    params[:user][:settings] = _settings
  end

end
