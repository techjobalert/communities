class SearchParams

  attr_reader :query, :sort, :page, :per_page

  def initialize(_params)
    @gparams = _params
    p = { self.class.per_page_param => 12, self.class.page_param => _params[:page] }
    p.merge!(_params)
    @query, @sort, @page, @per_page = p[self.class.query_param], p[self.class.sort_param], p[self.class.page_param], p[self.class.per_page_param]


    #@sort = nil unless @sort == 'newest' || @sort == 'oldest'
  end

  def get_search_results
    return nil unless @query
    options = {:star => true}
    # options.merge!(get_sort_options)
    options.merge!(get_paging_options)
    options.merge!({:classes => [*@gparams[:classes]]})
    if Item.in? [*@gparams[:classes]]
      options.merge!(get_item_options(@gparams) )
    end
    
    result = search_service.search @query, options
    return result
  end

  def by_relevance
    params = {self.class.query_param => @query}
    params.merge!(self.class.page_param => @page) unless @page.blank?
    params.merge!(self.class.per_page_param => @per_page) unless @per_page.blank?
    params
  end

  def by_relevance?
    !@sort
  end

  def newest_first
    by_relevance.merge self.class.sort_param => 'newest'
  end

  def oldest_first
    by_relevance.merge self.class.sort_param => 'oldest'
  end

  # Define query param name
  def SearchParams.query_param
    "q"
  end

  # Define sorting mode param name
  def SearchParams.sort_param
    "s"
  end

  # Define page param name
  def SearchParams.page_param
    "p"
  end

  # Define page param name
  def SearchParams.per_page_param
    "pp"
  end

  private
  def get_sort_options
    sort_options = {}
    if @sort == "newest"
      sort_options[:order] = "created_at"
      sort_options[:sort_mode] = :desc
    elsif @sort == "oldest"
      sort_options[:order] = "created_at"
      sort_options[:sort_mode] = :asc
    end
    sort_options
  end

  def get_paging_options
    paging_options = {}
    paging_options[:page] = @page unless @page.blank?
    paging_options[:per_page] = @per_page unless @per_page.blank?
    paging_options
  end

  def get_item_options(params)
    opt = []
    opt.push(items_order(params))
    if params[:current_user_id]
      opt.push(items_by_owner(params))
    else
      opt.push(items_only_published(params))
    end
    opt.push(items_date_interval(params))
    if params[:filter_type] != "account"
      opt.push(items_attachment_type(params))
    end
    if params[:following]
      opt.push(items_by_follower(params[:following]))
    end  
    opt.push(items_relevant_item(params))
    opt.push(items_views_filter(params))
    opt.push(items_price_filter(params))
    options = {}
    opt.each do |o|
      next if o.nil?
      o.each do |k,v|
        if options.include? k
          options[k].merge!(v) if v.is_a? Hash
          options[k] = v if v.is_a? String or v.is_a? Symbol
        else
          options.merge!({k => v})
        end
      end
    end
    options
  end

  def items_order(params)
    {:order => "created_at", :sort_mode =>:desc }
  end

  def items_relevant_item params
    if params[:relevant_item_id].present?
      item = Item.find params[:relevant_item_id]
      { :without_ids => [*item.id], :with_all => { :tag_ids => item.tag_ids }, :classes => [Item]}
    end
  end

  def items_attachment_type(params)
    attachment_types = ["video","article","presentation"]
    if params[:filter_type].present?
      attachment_type = if params[:attachment_type].present?
        attachment_types.include?(params[:attachment_type]) ? params[:attachment_type] : "video"
      else
        "video"
      end

      { :with => { :attachment_type => attachment_type.to_crc32 } }
    end
  end

  def items_date_interval(params)
    if params[:date] and not params[:date].blank?
      date = case params[:date]
      when "Today"
        Date.today.to_time..Time.now
      when "1 Week"
        (Time.now.weeks_ago 1)..Time.now
      when "1 Month"
        (Time.now.months_ago 1)..Time.now
      when "1 Year"
        (Time.now.years_ago 1)..Time.now
      else
        Time.zone.now..Time.now
      end
      { :with => {:created_at => date} }
    end
  end

  def items_views_filter(params)
    if params[:views] and not params[:views].blank?
      sort_options = {}
      sort_options[:order] = "views_count"
      sort_options[:sort_mode] = case params[:views]
      when "More Viewed"
        :desc
      when "Less Viewed"
        :asc
      end
      sort_options
    end
  end

  def items_price_filter(params)
    if params[:price] and not params[:price].blank?
      case params[:price]
      when "Free"
        { :with => {:price => 0 } }
      when "Paid"
        { :without => {:price => 0} }
      end
    end
  end


  def items_by_follower(follower_id)
    { :with => {:follower_ids => follower_id}}
  end

  def items_by_owner(params)
    { :with => {:user_id => params[:current_user_id] }, :without => {:state => "archived".to_crc32} }
  end

  def items_only_published(params)
    { :with => {:state => "published".to_crc32} }
  end

  private

  def search_service
    SearchService.new
  end

end