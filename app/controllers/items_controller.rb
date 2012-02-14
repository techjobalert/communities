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

end
