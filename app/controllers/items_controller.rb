class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource
  

  def show 
    @item = Item.find(params[:id])    
    @popup = (params[:type].present? && params[:type] == "popup")       
  end

  def index
    @items = Item.published.page params[:page]
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
    @following_item = Item.find(params[:item_id])
    @message = ""
    if @following_item and not current_user.items.include?(@following_item)
      current_user.follow(@following_item)
    else
      @message = "You cannot follow your item."
    end

    respond_to do |format|
      format.js     
    end
  end

  def unfollow
    @following_item = Item.find(params[:item_id])
    @message = ""
    if current_user.following?(@following_item) and @following_item
      current_user.stop_following(@following_item)
    else
      @message = "Some error."
    end
    respond_to do |format|
      format.js     
    end
  end
end
