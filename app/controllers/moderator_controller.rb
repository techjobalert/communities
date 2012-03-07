class ModeratorController < ApplicationController
  layout "administrator"
  before_filter :is_admin
  before_filter :get_item, :only => [:item_show, :item_publish, :item_deny]
  before_filter :get_comment, :only => [:comment_publish, :comment_deny]

  def items
    @items = Item.state_is("moderated").page(params[:page]).per(3)
    @notice = params[:notice]
  end

  def item_show
  end

  def item_publish    
    if @item.publish
      notice = {:type => 'notice', :message => "Item is confirmed"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(moderator_path(:notice => notice))
  end

  def item_deny
    if @item.deny
      notice = {:type => 'notice', :message => "Item is denied"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(moderator_path(:notice => notice))
  end

  def comments
    @comments = Comment.state_is("moderated").page(params[:page]).per(20)
    @notice = params[:notice]
  end

  def comment_publish    
    if @comment.publish
      notice = {:type => 'notice', :message => "Comment is confirmed"}
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
  end

  def get_comment
    @comment = Comment.find params[:id]
  end

  def is_admin
    redirect_to root_path unless current_user.admin?
  end
end
