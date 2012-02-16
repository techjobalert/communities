class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource
  
  def index
    @items = Item.page params[:page]
  end
  
  def create
    params[:item]['user_id'] = current_user.id
    @item = Item.new(params[:item])
 
    respond_to do |format|
      if @item.save
        format.html {redirect_to(@item, 
          :notice => 'Item was successfully created.') }       
      else
        format.html {render :action => "new"}        
      end
    end
  end  

  def follow
    following_subject = Item.find(params[:item_id])
    @message = ""
    if not current_user.items.include?(following_subject.id) and following_subject
      current_user.follow(following_subject)
    else
      @message = "You cannot follow your item."
    end

    respond_to do |format|
      format.js     
    end
  end

  def unfollow
    following_subject = Item.find(params[:item_id])
    @message = ""
    if urrent_user.following?(following_subject) and following_subject
      current_user.stop_following(following_subject)
    else
      @message = "Some error."
    end
    respond_to do |format|
      format.js     
    end
  end
end
