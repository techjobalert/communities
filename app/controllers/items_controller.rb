class ItemsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [:show, :index, :search, :qsearch, :get_attachment]
  before_filter :get_item, :except => [:index, :new, :create, :tags, :get_attachment]
  load_and_authorize_resource


  def show
    if (params[:type].present? && params[:type] == "popup")
      @popup = true
    else
      @popup = false
      @item.increment!(:views_count)

      @a_pdf, @a_video = @item.regular_pdf, @item.common_video unless @item.attachments.blank?

      # @hash = SecureRandom.hex(12)

      # if @a_pdf
      #   unless @a_pdf.nil? and @a_pdf.file_processing == true
      #     pdf = @a_pdf.is_processed_to_pdf? ? @a_pdf.file.pdf : @a_pdf.file
      #     $redis.hset(@hash,'pdf', pdf.url)
      #   end
      # end

      # if @a_video
      #   unless @a_video.nil? and @a_video.file_processing == true
      #     video = request.user_agent =~ /Mobile|webOS|iPhone/ ? @a_video.file.mobile : @a_video.file.mp4
      #     $redis.hset(@hash,'mp4', @a_video.file.mp4.url)
      #     $redis.hset(@hash,'webm', @a_video.file.webm.url)
      #     $redis.hset(@hash,'mobile', video.url)
      #   end
      # end

    end
  end

  def get_attachment
    Rails.logger.info "----#{params}"
    send_file "#{Rails.root}/public/uploads/attachment/file/#{params[:file_id]}/#{params[:basename]}.#{params[:extension]}", :x_sendfile => true
  end

  def index
    @items = Item.state_is("published").order("created_at DESC").page(params[:page])
  end

  def new

  end

  def edit
    @step = params[:step]
    unless @item.attachments.blank?
      @a_pdf, @a_video = @item.regular_pdf, @item.regular_video
      @processed = ((@a_video and not @a_video.file_processing? == true) or (@a_pdf and not @a_pdf.file_processing? == true))
      @uuid = SecureRandom.uuid.split("-").join()
    end
  end

  def update
    @step = params[:step]
    @current_step = params[:current_step]
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

    @item.attributes = params[:item]

    @item.edit if @item.changed? or tag_list_changed or paypal_account_changed

    if @item.save and @current_step == 'additional'
      @notice = { :type => "notice", :message => "Item is saved." }
    end

    if params[:publish]
      if @item.attachments
        if @processed
          @item.moderate
          @item.save
          @notice = { :type => "notice",
              :message => "Item will be published after premoderation." }
          @step = @current_step
        else
          @notice = { :type => "error",
            :message => "Please wait for the attached file to be processed. Publishing will be available after processing." }
          @step = @current_step
        end
      else
        @notice = { :type => "error",
          :message => "Item can't be published without attached files" }
        @step = "upload"
      end
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
      .page(params[:page]).per(3)
  end

  def relevant
    params[:attachment_type] ||= 'video'
    params.merge!({:classes => [Item], :relevant_item_id => @item.id})
    params.merge!({SearchParams.per_page_param => 3})

    @items = SearchParams.new(params).get_search_results
  end

  def search
    @content_type = params[:attachment_type] || 'video'
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
      @user = User.find(params[:user_id])
      if @user == current_user
        @notice = {:type => "error",
          :message => "You can't remove yourself from contributors"}
      elsif not @item.contributors.include? @user
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
    options = {
      :user => current_user,
      :file => params[:file],
      :attachment_type  => params[:attachment_type] || "regular",
      :item_id => @item.id
    }
    # delete last file by type
    base_upload(klass, params, options)
  end

  def merge_presenter_video
    record_file = File.open(
      File.expand_path(
        File.join(Rails.root, "..","video","webcam_records","#{params[:record_file_name]}")
      )
    )
    presenter_video = Attachment.new({
      :file => record_file,
      :user => current_user,
      :attachment_type => "presenter_video"})

    @item.attachments << presenter_video

    video = Attachment.find(params[:video_id])
    if video.attachment_type == "presentation_video" and params[:playback_points].present?
      Resque.enqueue(ProcessPresentationVideo, params[:video_id], presenter_video.id, {:playback_points => params[:playback_points].values, :position => params[:position]})
    else
      Resque.enqueue(VideoMerge, params[:video_id], presenter_video.id, {:position => params[:position]})
    end

    @notice = {:type => 'notice', :message =>
        "your files added to Q for merging"
      }
    render :partial => "layouts/notice", :locals => {:notice => @notice}
  end

  def pdf_page
    file, page = params[:file], params[:page].to_i if params[:page].present?
    file = Item.find(params[:item_id]).attachments.first.file.document
    reader = PDF::Reader.new("public/"+file.to_s)
    page     = reader.page(page)
    @content  = page.raw_content
  end

  def change_price
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

  def base_upload(klass, params, options)
    begin
      russian_translit!(params)
      last_attachemnt = Attachment.where(
        :item_id => options[:item_id],
        :attachment_type => options[:attachment_type]).last
      last_attachemnt.destroy if last_attachemnt
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
