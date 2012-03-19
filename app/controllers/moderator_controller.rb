class ModeratorController < ApplicationController
  authorize_resource :class => false

  layout "administrator"
  before_filter :get_item, :only => [:item_show, :item_publish, :item_deny]
  before_filter :get_comment, :only => [:comment_publish, :comment_deny]

  def items
    @items = Item.state_is("moderated").order("created_at desc").page(params[:page]).per(3)
    @notice = params[:notice]
  end

  def item_show
  end

  def item_publish
    options = params[:message] = {:receiver_id => @item.user_id, :title => @item.title}

    @message = Message.new(options, params)
    @item.moderated_at = Time.now
    @item.approved_by = current_user

    if @message.save and @item.publish
      notice = {:type => 'notice',
        :message => "Item is published. Message was successfully sended."}
      Resque.enqueue(SendModerationMessage, @message.id)
    else
      notice = {:type => 'error',:message => "Error. Message not created."}
    end

    redirect_to(moderator_path(:notice => notice))
  end

  def item_deny
    options = params[:message].merge!(
      {
        :user_id => current_user.id,
        :receiver_id => @item.user_id,
        :title => @item.title
      }
    )

    @message = Message.new(options, params)
    @item.moderated_at = Time.now

    if params[:message].blank? || params[:message][:body].blank?
      @notice = {:type => 'error', :message => "Deny reason text can't be blank."}
    else
      if @message.save and @item.deny
        @notice = {:type => 'notice',
          :message => "Item is denied. Message was successfully sended."}
        Resque.enqueue(SendModerationMessage, @message.id)
      else
        @notice = {:type => 'error',:message => "Error. Message not created."}
      end

      redirect_to(moderator_path(:notice => @notice))
    end
  end

  def comments
    @comments = Comment.state_is("moderated").page(params[:page]).per(20)
    @notice = params[:notice]
  end

  def comment_publish
    if @comment.publish
      notice = {:type => 'notice', :message => "Comment is published"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(moderator_comments_path(:notice => notice))
  end

  def comment_deny
    if @comment.destroy
      notice = {:type => 'notice', :message => "Comment is denied"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(moderator_comments_path(:notice => notice))
  end

  protected

  def get_item
    @item = Item.find params[:id]
    unless moderated?(@item)
      redirect_to moderator_path
    end
  end

  def get_comment
    @comment = Comment.find params[:id]
    unless moderated?(@comment)
      redirect_to moderator_comments_path
    end
  end

  def moderated?(obj)
    obj.try(:state) == "moderated"
  end
  # def is_admin
  #  redirect_to root_path unless current_user.admin?
  # end

end
