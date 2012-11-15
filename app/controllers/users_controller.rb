class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource

  def index
    @tab = if current_user.role?("doctor")
      params[:tab].present? ? params[:tab] : 'followers'
    else
      'following'
    end

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
    @user = (user_signed_in? && params[:id] == current_user.id) ? current_user : User.find(params[:id])
    @collaborators = User.collaborators @user
    @type = params[:type].present? ? params[:type] : "profile"
  end

  def edit
    @notice = params[:notice] if params[:notice].present?
  end

  def update
    respond_to do |format|
      unless params[:user][:birthday].blank? or params[:user][:birthday].nil?
        params[:user][:birthday] = Date.strptime(params[:user][:birthday], "%m/%d/%Y")
      end

      @paypal_account_change = params[:paypal_account_change].present? ? true : false

      if current_user.update_attributes params[:user]
        @notice = {:type => 'notice', :message => "Profile successfully updated."}
        if  params[:type].present? &&  params[:type] == "profile"
          format.html { redirect_to user_path(current_user, :type => "profile")}
          format.js
        else
          format.html { redirect_to edit_user_path(current_user, :notice => @notice)}
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
    current_user.crop_x = nil
    current_user.crop_y = nil
    current_user.crop_w = nil
    current_user.crop_h = nil
    current_user.avatar = params[:file]

    if current_user.save
      @data = {:url  => current_user.avatar_url()}
      render :json => @data.to_json, :content_type => "text/json; charset=utf-8"
    else
      @notice = {:type => 'error', :message =>
        "#{t current_user.errors.keys.first} #{current_user.errors.values.first.first.to_s}"
      }
      render :partial => "layouts/notice", :locals => {:notice => @notice}
    end

  end

  def crop_avatar

    current_user.crop_x = params[:coords]["x"]
    current_user.crop_y = params[:coords]["y"]
    current_user.crop_h = params[:coords]["h"]
    current_user.crop_w = params[:coords]["w"]
    current_user.save!
    current_user.avatar.recreate_versions!

    rand = Time.now.to_i

    @data = {
        :thumb_45  => "#{current_user.avatar_url(:thumb_45)}?#{rand}",
        :thumb_60  => "#{current_user.avatar_url(:thumb_60)}?#{rand}",
        :thumb_70  => "#{current_user.avatar_url(:thumb_70)}?#{rand}",
        :thumb_143 => "#{current_user.avatar_url(:thumb_143)}?#{rand}"
      }

    render :json => @data.to_json, :content_type => "text/json; charset=utf-8"

  end

  def follow
    following_user_id = params[:user_id]
    @message = ""
    if following_user_id != current_user.id
      @following_user = User.find(following_user_id)
      current_user.follow(@following_user)
    else
      @message = "You can't follow your self."
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
      user_followers = current_user.followers.each do |f|
        options = params[:message].merge!({:receiver_id => f.id, :user_id => current_user.id})
        @message = Message.new(options, params)
        if @message.save
          sended_messages_count += 1
          Resque.enqueue(SendMessage, @message.id)
        end
      end
      user_followers.map!(&:id)
      user_collaborators = User.collaborators(current_user).map(&:id) - user_followers 
      user_collaborators.each do |c|
        options = params[:message].merge!({:receiver_id => c, :user_id => current_user.id})
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
        :message => "Messages isn't sended because you haven't followers"}
      else
        @notice = {:type => 'error',:message => "Error. Messages send."}
      end
    end
  end

  def search
    options = {:star => true}
    if params[:degree].present? 
      options.merge!(:with => {:degree => params[:degree].to_crc32})
    end
    _users = User.search(params[:q], options)
    Rails.logger.info "--- options: #{options} --- _users: #{_users} -----"
    ids = case params[:filter_type]
    when "following"
      current_user.following_by_type('User').map{|x| x.id}
    when "published_together"
      User.collaborators(current_user).map{|f| f.id}
    when "followers"
      current_user.followers.select { |f| f.role?("doctor")}.map{|f| f.id}
    when "patients"
      current_user.followers.map {|f| f.id if f.role?("patient")}
    end
    Rails.logger.info " --- ids: #{ids} -----"
    if ids
      @users = _users.select {|u| u and u.id.in? ids }
    else
      @users = _users
    end
  end

  def validate_card

  end

end
