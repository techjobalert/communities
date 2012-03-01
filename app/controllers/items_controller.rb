class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index]
  before_filter :get_item, :except => [:index, :new, :create]
  load_and_authorize_resource


  def show
    if (params[:type].present? && params[:type] == "popup")
      @popup = true
    else
      @popup = false
      @item.increment!(:views_count)
      #TODO: create with Sphinx search
      # @items = Item.search(
      #   :with_all => {
      #     :tag_ids => @item.tags.collect(&:id),
      #     :title => @item.title
      #   }
      @items = Item.except(@item).where('title LIKE ? ', "%#{@item.title}%")
      @items = @items.tagged_with(@item.tag_list,:any => true).page params[:page]
    end
  end

  def index
    @items = Item.published.page params[:page]
  end

  def new

  end

  def edit

  end

  def update
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
    @item.deleted = true
    notice = @item.save ? {:type => 'notice', :message => "successfully"}
      : {:type => 'error', :message => "Some error."}

    redirect_to(items_account_path(:notice => notice))
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