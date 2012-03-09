class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index, :search, :qsearch]
  before_filter :get_item, :except => [:index, :new, :create, :tags]
  load_and_authorize_resource


  def show
    if (params[:type].present? && params[:type] == "popup")
      @popup = true
    else
      @popup = false
      @item.increment!(:views_count)
      @items = Item.search(:q => @item.title, :tags => @item.tag_list)
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

    if params[:tag_list].present?
      tag_list = JSON::parse(params[:tag_list])
      @item.tag_list = tag_list
    end

    if @item.update_attributes params[:item]
      @notice = {:type => "notice",
        :message => "Item is updated. Item will be published after premoderation"}
    else
      @notice = {:type => "error", :message => "error"}
    end

    @type = params[:type].present? ? params[:type] : false
  end

  def create
    params[:item]['user_id'] = current_user.id
    @item = Item.new(params[:item])
    if @item.save
      @notice = {:type => 'notice',
        :message => "Item is created. Item will be published after premoderation"}
    else
      @notice = {:type => 'error', :message => "Some error."}
    end
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
      notice = {:type => 'notice', :message => "Item is deleted"}
    else
      notice = {:type => 'error', :message => "Some error."}
    end

    redirect_to(items_account_path(:notice => notice))
  end

  def search
    @render_items, @filter_location = params[:filter_type], params[:filter_location]
    params[:current_user_id] = current_user.id if @render_items == "account"
    params.merge!({SearchParams.per_page_param => 3}) if @filter_location != "main"
    params.merge!({:classes => [Item]})
    p params
    @items = SearchParams.new(params).get_search_results
  end

  def qsearch
    _params = {
      SearchParams.query_param => params[:term],
      SearchParams.page_param => 1,
      SearchParams.per_page_param => 5,
      :classes => [Item]
    }
    search_params = SearchParams.new(_params)
    results = search_params.get_search_results || []
    @search_results = results.map do |item|
      {
        :title => item.title.truncate(40, :separator => ' '),
        :content => item.description.truncate(50, :separator => ' '),
        :url => polymorphic_path(item)
      }
    end
    render :json => @search_results
  end

  def tags
    tags = Item.tag_counts

    respond_to do |format|
      format.json { render :json => get_tag_names(tags).to_json }
    end
  end

  protected

  def get_item
    if params[:id].present?
      @item = Item.find(params[:id])
    elsif params[:item_id].present?
      @following_item = Item.find(params[:item_id])
    end
  end

  def get_tag_names(tags)
    data = []

    tags.each do |tag|
      data << tag.name
    end

    data
  end
end
