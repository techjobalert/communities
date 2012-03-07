class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index, :search, :qsearch]
  before_filter :get_item, :except => [:index, :new, :create]
  load_and_authorize_resource


  def show
    if (params[:type].present? && params[:type] == "popup")
      @popup = true
    else
      @popup = false
      @item.increment!(:views_count)
      @items = Item.except(@item).where('title LIKE ? ', "%#{@item.title}%")
      @items = @items.tagged_with(@item.tag_list,:any => true).page params[:page]
    end
  end

  def index
    @items = Item.state_is("published").order("created_at DESC").page params[:page]
  end

  def new

  end

  def edit

  end

  def update
    @item.moderate
    if @item.update_attributes params[:item]
      @notice = {:type => "notice", :message => "successfull"}
    else
      @notice = {:type => "error", :message => "error"}
    end

    @type = params[:type].present? ? params[:type] : false
  end

  def create
    params[:item]['user_id'] = current_user.id
    @item = Item.new(params[:item])
    @notice = @item.save ? {:type => 'notice', :message => "successfully"}
      : {:type => 'error', :message => "Some error."}
  end

  def follow
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

  def destroy
    if  @item.archive
      notice = {:type => 'notice', :message => "successfully"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(items_account_path(:notice => notice))
  end

  def search
    params[:current_user_id] = current_user.id
    @items = Item.search(params)
    @render_items = params[:filter_type]
  end

  def qsearch
    params[:load], params[:q] = true, params[:term]
    @search_results = Item.search(params)
    @search_results.map! do |item|
      {
        :title => item.title.truncate(40, :separator => ' '),
        :content => item.description.truncate(50, :separator => ' '),
        :url => polymorphic_path(item)
      }
    end
    render :json => @search_results
  end

  protected

  def get_item
    if params[:id].present?
      @item = Item.find(params[:id])
    elsif params[:item_id].present?
      @following_item = Item.find(params[:item_id])
    end
  end
end
