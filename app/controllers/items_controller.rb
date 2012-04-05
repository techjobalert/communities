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
      if not @item.attachments.blank?
        @a_pdf = @item.attachments.select{|a| a.is_pdf? or a.is_processed_to_pdf? }.last
        @attachment_pdf = @a_pdf.is_processed_to_pdf? ? @a_pdf.file.pdf : @a_pdf.file unless @a_pdf.nil?

        @a_video = @item.attachments.select{|a| a.is_processed_to_mp4?}.last
        @attachment_video = @a_video.is_processed_to_mp4? ? @a_video.file.mp4 : @a_video.file unless @a_video.nil?

      end
      @items = Item.search(
        :q => @item.title,
        :without_ids => [*@item.id],
        :with_all => {:tag_ids => @item.tag_ids},
        :with => {:state => "published".to_crc32},
        :without => {:state => "archived".to_crc32},
        :page => params[:page],
        :per_page => 3,
        :star => true)
    end
  end

  def index
    @items = Item.state_is("published").order("created_at DESC").page(params[:page])
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

    if attachment_ids = params[:item][:attachment_ids]
      attachments=Attachment.find(attachment_ids).each{ |a| @item.attachments << a }
    end

    if @item.update_attributes params[:item]
      if !params[:type].present? || params[:type] != "change_keywords"
        @notice = {:type => "notice", :message => "Item is updated. Item will be published after premoderation"}
      else
        @notice = {:type => "notice", :message => "Item is updated."}
      end
    else
      @notice = {:type => "error", :message => "error"}
    end

    @type = params[:type].present? ? params[:type] : false
  end

  def create
    params[:item]['user_id'] = current_user.id
    @item = Item.new(params[:item])

    if params[:tag_list].present?
      tag_list = JSON::parse(params[:tag_list])
      @item.tag_list = tag_list
    end

    if attachment_ids = params[:item][:attachment_ids]
      attachments=Attachment.find(attachment_ids).each{ |a| @item.attachments << a }
    end

    if @item.save
      @notice = {:type => 'notice',
        :message => "Item is created. Item will be published after premoderation"}
    else
      @notice = {:type => 'error', :message => "Some error."}
    end
  end

  def follow
    if @following_item and not current_user.items.include?(@following_item)
      current_user.follow(@following_item)
      @notice = {:type => 'notice', :message => "success"}
    else
      @notice = {:type => 'error', :message => "You can't follow your item."}
    end
  end

  def unfollow
    @message = ""
    if current_user.following?(@following_item) and @following_item
      current_user.stop_following(@following_item)
      @notice = {:type => 'notice', :message => "success"}
    else
      @notice = {:type => 'error', :message => "You can't unfollow your item."}
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
    @items = SearchParams.new(params).get_search_results
  end

  def users_search
    @item = Item.find(params[:item_id])
    @doctors = User.where("id not in (?) and full_name LIKE '%#{params[:q]}%' and role = ?", @item.contributor_ids, "doctor")
    # @doctors = User.search(params[:q], :without_ids => @item.contributor_ids, :with => {:role => "doctor"} )
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
    @search_results = results.select{|r| r.state == "published"}.map do |item|
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

  def add_to_contributors
    if params[:user_id]
      @item = Item.find(params[:item_id])
      @user = User.find(params[:user_id])
      if @item.contributors.include? @user
        @notice = {:type => "error",
          :message => "User already in contributors"}
      else
        @item.contributors << @user
        @item.save!
        @notice = {:type => "notice",
          :message => "User added to contributors"}
      end
    end
  end

  def delete_from_contributors
    if params[:user_id]
      @item = Item.find(params[:item_id])
      @user = User.find(params[:user_id])
      if not @item.contributors.include? @user
        @notice = {:type => "error",
          :message => "User is not in your contributors"}
      else
        @item.contributors.destroy(@user.id)
        @item.save!
        @notice = {:type => "notice",
          :message => "User deleted from contributors"}
      end
    end
  end

  def upload_attachment
    klass = Attachment
    options = {:user => current_user, :file => params[:file]}
    base_upload(klass, params, options)
  end

  def upload_precenter_video

    klass = PresenterVideo
    options = {
      :user  => current_user,
      :file  => params[:file],
      :type  => "source_video",
      :state => "transcoding"
    }
    base_upload(klass, params, options)
  end

  def pdf_page
    file, page = params[:file], params[:page].to_i if params[:page].present?
    file = Item.find(params[:item_id]).attachments.first.file.document
    reader = PDF::Reader.new("public/"+file.to_s)
    page     = reader.page(page)
    @content  = page.raw_content
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

  private

  def base_upload(klass, params, options)
    begin
      russian_translit!(params)
      obj = klass.create!(options)
      render :json => {:id => obj.id, :objClass => obj.class.name.underscore}, :content_type => "text/json; charset=utf-8"
    rescue ActiveRecord::RecordInvalid => invalid
      Rails.logger.error invalid.inspect
      @notice = {:type => 'error', :message =>
        "#{t current_user.errors.keys.first} #{current_user.errors.values.first.first.to_s}"
      }
      render :partial => "layouts/notice", :locals => {:notice => @notice}
    end
  end

  def russian_translit!(params)
    params[:file].original_filename = Russian.translit(params[:name])
    params
  end
end
