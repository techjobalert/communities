class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource

  def index
    @tab = params[:tab].present? ? params[:tab] : 'followers'

    case @tab
      when "followers"
        @users = current_user.followers.select { |f| f.role == 'doctor'}

      when "published_together"
        @users = User.collaborators current_user

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
    @collaborators = User.collaborators @user
    @type = params[:type].present? ? params[:type] : "public"
  end

  def edit
    # current_user.educations.build
  end

  def update
    respond_to do |format|
      if not params[:user][:birthday].nil?
        params[:user][:birthday] = Date.strptime(params[:user][:birthday], "%m/%d/%Y")
      end

      if current_user.update_attributes params[:user]
        # flash[:notice] = "success"
        @notice = {:type => 'notice', :message => "Profile successfully updated."}
        if  params[:type].present? &&  params[:type] == "profile"
          format.html { redirect_to user_path(current_user, :type => "profile")}
          format.js
        else
          format.html { redirect_to edit_user_path(current_user)}
          format.js
        end
      else
        flash[:error] = "error"
        @notice = {:type => 'error', :message =>
          "#{t current_user.errors.keys.first} #{current_user.errors.values.first.first.to_s}"
        }
        if  params[:type].present? &&  params[:type] == "profile"
          format.html { redirect_to user_path(current_user, :type => "profile")}
          format.js
        else
          format.html { redirect_to edit_user_path(current_user)}
          format.js
        end
      end
    end
  end

  def upload_avatar
    current_user.avatar = params[:file]
    respond_to do |format|
      if current_user.save
        @data = {
          :thumb_45 => current_user.avatar_url(:thumb_45),
          :thumb_60 => current_user.avatar_url(:thumb_60),
          :thumb_70 => current_user.avatar_url(:thumb_70),
          :thumb_143 => current_user.avatar_url(:thumb_143),
        }
        format.json { render :json => @data.to_json }
      else
        @notice = {:type => 'error', :message =>
          "#{t current_user.errors.keys.first} #{current_user.errors.values.first.first.to_s}"
        }
        format.js { render :partial => "layouts/notice", :locals => {:notice => @notice} }
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

    @message = Message.new(options, params)

    if params[:message].blank? || params[:message][:body].blank?
      @notice = {:type => 'error', :message => "Message text can't be blank."}
    else
      if @message.save
        @notice = {:type => 'notice',
          :message => "Message was successfully sended."}
        Resque.enqueue(SendMessage, @message.id)
      else
        @notice = {:type => 'error',:message => "Error. Message not created."}
      end
    end

  end

  def send_message_to_followers
    sended_messages_count = 0
    @notice = {}
    if params[:message].blank? || params[:message][:body].blank?
      @notice = {:type => 'error', :message => "Message text can't be blank."}
    else
      current_user.followers.each do |f|
        options = params[:message].merge!({:receiver_id => f.id, :user_id => current_user.id})
        @message = Message.new(options, params)
        if @message.save
          sended_messages_count += 1
          Resque.enqueue(SendMessage, @message.id)
        end
      end
      if sended_messages_count != 0
        @notice = {:type => 'notice',
        :message => "Messages was successfully sended to #{sended_messages_count} followers"}
      elsif sended_messages_count == 0
        @notice = {:type => 'error',
        :message => "Messages isn't sended becouse you haven't followers"}
      else
        @notice = {:type => 'error',:message => "Error. Messages send."}
      end
    end
  end

end
