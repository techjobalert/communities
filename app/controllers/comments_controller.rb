# -*- coding: utf-8 -*-
class CommentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def create
    @item = Item.find(params[:item_id])
    
    if params[:comment].blank? || params[:comment][:body].blank?
      @notice = {:type => 'error', :message => "Body can't be blank."}
    else      
      @comment = @item.comment_threads.build_from(
        @item, current_user.id, params[:comment][:body])

      if @comment.save
        @notice = {:type => 'notice', 
          :message => "Comment was successfully created."}        
      else
        @notice = {:type => 'error', 
          :message => "Error. Comments not created."}
      end      
    end  
  end

  def vote_up
    @comment = Comment.find(params[:comment_id])
    @comment.liked_by current_user
  end

end