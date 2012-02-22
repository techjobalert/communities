class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource

  def index
    @tab = params[:tab].present? ? params[:tab] : 'followers'

    case @tab
      when "followers"
        @users = current_user.followers.select { |f| f.role == 'doctor'}       

      when "published_together"
        @users = User.all

      when "following"
        @users = current_user.following_by_type('User')        

      when "patients"
        @users = current_user.followers.select { |f| f.role == 'patient'}  

      else
        @users = current_user.followers.select { |f| f.role == 'doctor'} 
        @tab = "followers"    
    end
  end  

  def show 
    @user = params[:id] == current_user.id ? current_user : User.find(params[:id])
    @type = params[:type].present? ? params[:type] : "public"
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
        flash[:notice] = "success"
        if  params[:type].present? &&  params[:type] == "profile"
          format.html { redirect_to user_path(current_user, :type => "profile")}
        else 
          format.html { redirect_to edit_user_path(current_user)}
        end        
      else
        flash[:error] = "error"
        if  params[:type].present? &&  params[:type] == "profile"
          format.html { redirect_to user_path(current_user, :type => "profile")}
        else 
          format.html { redirect_to edit_user_path(current_user)}
        end  
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

  def send_message

    options = params[:message].merge!({:receiver_id => params[:user_id], :user_id => current_user.id})
    @message = Message.new(options)    

    if params[:comment].blank? || params[:message][:body].blank?
      @notice = {:type => 'error', :message => "Message text can't be blank."}
    else      
      if @message.save
        @notice = {:type => 'notice', 
          :message => "Message was successfully sended."}        
      else
        @notice = {:type => 'error', 
          :message => "Error. Message not created."}
      end      
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
