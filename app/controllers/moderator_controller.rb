class ModeratorController < ApplicationController
  layout "administrator"
  before_filter :is_admin
  before_filter :get_item, :only => [:item_show, :item_publish, :item_deny]
  before_filter :get_comment, :only => [:comment_publish, :comment_deny]

  def items
    @items = Item.state_is("moderated").page(params[:page]).per(3)
  end

  def item_show
  end

  def item_publish
    @item.publish
    redirect_to moderator_path
  end

  def item_deny
    @item.deny
    redirect_to moderator_path
  end

  def comments
    @comments = Comment.state_is("moderated").page(params[:page]).per(20)
  end

  def comment_publish
    @comment.publish
    redirect_to moderator_comments_path
  end

  def comment_deny
    @comment.destroy
    redirect_to moderator_comments_path
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
