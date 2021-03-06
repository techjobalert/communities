class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index, :search, :qsearch, :get_pdf_json]
  before_filter :get_item, :except => [:index, :new, :create, :tags, :upload_attachment]
  
  load_and_authorize_resource :except => :get_pdf_json


  def show
    if (params[:type].present? && params[:type] == "popup")
      @popup = true
    else
      @popup = false
      @item.increment!(:views_count)

      @a_pdf = @item.regular_pdf;
      @a_video = @item.common_video unless @item.attachments.blank?
    end

    @notice = params[:notice] if params[:notice]
  end

  def index
    @items = Item.state_is("published").order("created_at DESC").page(params[:page])
  end

  def following
  end

  def get_pdf_json
    detail = Attachment.find(params[:attachment_id]).document_detail
    count = (@item.preview_length <= detail.page_count) ?  @item.preview_length : detail.page_count
    width,height = detail.page_width,detail.page_height
    json_array = Array.new(count) { |i| {"number" => i+1,
      "fonts" => [], "text" => [], "width" => width, "height" => height} }
    render :json => json_array
  end

  def new
    @item = Item.new(
      :title        => "[no title]",
      :description  => "[no abstract]",
      :user_id      => current_user.id )

    @item.save( :validate => false )

    redirect_to edit_item_path(@item)
  end

  def edit
    unless @item.attachments.blank?
      @a_pdf, @a_video = @item.regular_pdf, @item.regular_video
      @processed = ((@a_video and not @a_video.file_processing? == true) or (@a_pdf and not @a_pdf.file_processing? == true))
      @uuid = SecureRandom.uuid.split("-").join()
    end
    # if current_user.social_account_credential.present?
    #   current_user.refresh_gmail_token
    #   @gmail_contacts = current_user.gmail_contacts.select {|c| !c[:email].blank? }
    # else
    #   @gmail_contacts = nil
    # end
  end

  def update
    @a_pdf, @a_video = @item.regular_pdf, @item.regular_video if @item.attachments
    @processed = ((@a_video and not @a_video.file_processing? == true) or (@a_pdf and not @a_pdf.file_processing? == true))
    @uuid = SecureRandom.uuid.split("-").join()

    tag_list_changed = false
    paypal_account_changed = false

    paypal_account = params[:paypal_account]

    if paypal_account and @item.user.paypal_account != paypal_account
      @item.user.update_attribute(:paypal_account, paypal_account)
      paypal_account_changed = true
    end

    if params[:tag_list].present?
      tag_list = JSON::parse(params[:tag_list])
      if @item.tag_list != tag_list
        @item.tag_list = tag_list
        tag_list_changed = true
      end
    end

    update_contributors params[:added_users].split(",")
    delete_from_contributors params[:deleted_users].split(",")

    @item.attributes = params[:item]

    if @item.changed? or tag_list_changed or paypal_account_changed
      @notice = { :type => "notice", :message => "Item will be published after premoderation." }
    else
      @notice = { :type => "notice", :message => "Item is saved." }
    end

    @item.moderate
    @item.save

    redirect_to(item_path(@item, :notice => @notice))
  end

  def update_preview
    if @item.update_attributes(params[:item])
      @notice = { :type => "notice", :message => "Preview length is updated." }
    else
      @notice = {:type => 'error', :message => "#{@item.errors.full_messages.first}."}
    end
  end

  def create
    params[:item]['user_id'] = current_user.id
    @item = Item.new(params[:item])

    if params[:tag_list].present?
      tag_list = JSON::parse(params[:tag_list])
      @item.tag_list = tag_list
    end

    if @item.save
      @notice = {:type => 'notice', :message => "Item is created."}
    end
  end

  def follow
    if @item and not current_user.items.include?(@item)
      current_user.follow(@item)
      @notice = {:type => 'notice', :message => "success"}
    else
      @notice = {:type => 'error', :message => "You can't follow your item."}
    end
  end

  def unfollow
    @message = ""
    if current_user.following?(@item) and @item
      current_user.stop_following(@item)
      @notice = {:type => 'notice', :message => "success"}
    else
      @notice = {:type => 'error', :message => "You can't unfollow your item."}
    end
  end

  def destroy
    @notice = if  @item.archive
      {:type => 'notice', :message => "Item is deleted"}
    else
      {:type => 'error', :message => "Some error."}
    end

    @items  = current_user.items
      .published
      .page(params[:page]).per(30)
  end

  def relevant
    params[:attachment_type] ||= 'video'
    params.merge!({:classes => [Item], :relevant_item_id => @item.id})
    params.merge!({SearchParams.per_page_param => 3})

    @items = SearchParams.new(params).get_search_results
  end


  def search
    @content_type = params[:attachment_type] || 'video'
    @following = params[:following]
    @render_items, @filter_location = params[:filter_type], params[:filter_location]
    params[:current_user_id] = current_user.id if @render_items == "account"
    params.merge!({SearchParams.per_page_param => 30}) if @filter_location != "main"
    params.merge!({:classes => [Item]})
    #add current community
    add_community_id_to_params(params)
    @items = SearchParams.new(params).get_search_results
  end

  def add_community_id_to_params params
    
    community_id = session[:community_id] if session[:community_id]
    community_id = params[:community_id] if params[:community_id]
    
    if(community_id)
      params.merge!({:community_ids => [ community_id ]})
    end
  end

  private :add_community_id_to_params

  def users_search
    @item = Item.find(params[:item_id])
    @doctors = User.where("id not in (?) and full_name LIKE '%#{params[:q]}%' and role = ?", [current_user.id], "doctor")
    # @doctors = User.search(params[:q], :without_ids => @item.contributor_ids, :with => {:role => "doctor"} )
  end

  def qsearch
    _params = {
      SearchParams.query_param => params[:term],
      SearchParams.page_param => 1,
      SearchParams.per_page_param => 5,
      :classes => [Item]
    }
    [:filter_type, :price, :attachment_type, :date].each do |param_name|
      if params[param_name]
        _params.merge!({param_name => params[param_name]})
      end
    end
    add_community_id_to_params(_params)
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

  def upload_attachment
    klass = Attachment

    if params[:item_id]
      @item = Item.find(params[:item_id])

      options = {
        :user             => current_user,
        :user_id          => current_user.id,
        :file             => params[:file],
        :attachment_type  => params[:attachment_type] || "regular",
        :item_id          => @item.id,
        :file_processing  => true
      }

      # delete last file by type
      base_upload(klass, params, options)
    end
  end

  def merge_presenter_video
    webcam_record_path = File.expand_path(
      File.join(Rails.root, "..","video","webcam_records","#{params[:record_file_name]}")
    )
    # add metadata before merge video
    w_dir     = File.dirname(webcam_record_path)
    w_file    = File.basename(webcam_record_path,".*")+"with_meta.flv"
    w_file_24 = File.basename(webcam_record_path,".*")+"with_meta_24fps.flv"
    wr_with_meta_data, wr_24fps = File.join(w_dir, w_file), File.join(w_dir, w_file_24)
    %x[yamdi -i #{webcam_record_path} -o #{wr_with_meta_data}]
    %x[ffmpeg -i #{wr_with_meta_data} -r 24 -ar 44100 -isync #{wr_24fps}]
    presenter_video = Attachment.new({
      :file => File.open(wr_24fps),
      :user => current_user,
      :attachment_type => "presenter_video"})

    # Removing source file
    # FileUtils.rm([webcam_record_path, wr_with_meta_data, wr_24fps], :verbose => true)
    # Remove prev presenter_video attachments -> move this to model :after_create

    @item.attachments << presenter_video

    video = Attachment.find(params[:video_id])

    if video.attachment_type == "presentation_video" and params[:playback_points].present?
      Resque.enqueue(ProcessPresentationVideo, params[:video_id], presenter_video.id, {:playback_points => params[:playback_points].values, :position => params[:position]})
    else
      Resque.enqueue(VideoMerge, params[:video_id], presenter_video.id, {:position => params[:position]})
    end

    @notice = {:type => 'notice', :message => "your files added to Q for merging" }
    render :partial => "layouts/notice", :locals => {:notice => @notice}
  end

  def pdf_page
    file, page = params[:file], params[:page].to_i if params[:page].present?
    file = Item.find(params[:item_id]).attachments.first.file.document
    reader = PDF::Reader.new("public/"+file.to_s)
    page     = reader.page(page)
    @content  = page.raw_content
  end

  #TODO: clean up!
  def _change_price
    @item = Item.find(params[:item_id])
    @item.attributes = params[:item]

    if @item.changed?
      if @item.state == "published"
        @item.moderate
        additional_message = " Item will be published after premoderation."
      end
      @item.save
      @notice = {
        :type => "notice",
        :message => "Item is updated.#{additional_message}" }
    end
  end

  def change_price
    #extract parameters
    item_id = params[:item_id]
    price = params[:item][:price]
    
    #execute business logic
    item_service.change_price(item_id, price)

    @notice = {
        :type => "notice",
        :message => "Item price is updated" }
  end

  def change_keywords
    @item = Item.find(params[:item_id])

    if params[:tag_list].present?
      tag_list = JSON::parse(params[:tag_list])
      @item.tag_list = tag_list
    end

    if @item.save
      @notice = {:type => "notice", :message => "Item is updated"}
    else
      @notice = {:type => "error", :message => "error"}
    end
  end

  protected

  def get_item
    Rails.logger.info params
    @item = if params[:id].present?
      Item.find(params[:id])
    elsif params[:item_id].present?
      Item.find(params[:item_id])
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

  def item_service
    ItemService.new
  end

  def update_contributors user_ids
    user_ids ||=[]
    user_ids.each do |id|
      user = User.find id
      unless @item.contributors.include? user
        @item.contributors << user
      end
    end
    @item.save!
  end

  def delete_from_contributors user_ids
    user_ids ||=[]
    user_ids.each do |id|
      user = User.find id
      unless user == current_user and @item.contributors.include? user
        @item.contributors.destroy(user.id)
      end
    end
    @item.save!
  end

  def base_upload(klass, params, options)
    begin
      russian_translit!(params)
      last_attachment = Attachment.where(
        :item_id => options[:item_id],
        :attachment_type => options[:attachment_type]).last

      if last_attachment && last_attachment.file_processing
        @notice = {:type => 'error', :message =>
          "can't replace file before processing"
        }
        render :partial => "layouts/notice", :locals => {:notice => @notice}
      else
        if last_attachment
          last_attachment.destroy
        end
        obj = klass.create!(options)
        @item = Item.find options[:item_id]
        @item.moderate
        render :json => {:id => obj.id, :objClass => obj.class.name.underscore, :itemID => options[:item_id]}, :content_type => "text/json; charset=utf-8"
      end

    rescue ActiveRecord::RecordInvalid => invalid

      Rails.logger.error invalid.inspect
      @notice = {:type => 'error', :message => invalid.message}
      render :partial => "layouts/notice", :locals => {:notice => @notice}
    end
  end

  def russian_translit!(params)
    params[:file].original_filename = Russian.translit(params[:name])
    params[:file].original_filename = params[:file].original_filename.gsub("\s","_")
    params
  end
end
