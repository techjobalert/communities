class SearchParams

  attr_reader :query, :sort, :page, :per_page

  def initialize(_params)
    @gparams = _params
    p = {self.class.per_page_param => 12}
    p.merge!(_params)
    @query, @sort, @page, @per_page = p[self.class.query_param], p[self.class.sort_param], p[self.class.page_param], p[self.class.per_page_param]
    @sort = nil unless @sort == 'newest' || @sort == 'oldest'
  end

  def get_search_results
    return nil unless @query

    options = {:star => true}
    options.merge!(get_sort_options)
    options.merge!(get_paging_options)
    if Item.in? [*@gparams[:classes]]
      options.merge!({:classes => [*@gparams[:classes]]})
      options.merge!(get_item_options(@gparams) )
    end
    ThinkingSphinx.search @query, options
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
    options = {}
    options.merge!(item_date_interval(params)||{})
    options.merge!(item_views_filter(params)||{})
    options.merge!(item_price_filter(params)||{})
    options.merge!(items_by_owner(params)||{}) if params[:current_user_id]
    options
  end

  def item_date_interval(params)
    if params[:date] and not params[:date].include?("Any")
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
  def item_views_filter(params)
    if params[:views] and not params[:views].include?("Any")
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
  def item_price_filter(params)
    if params[:price] and not params[:price].include?("Free/Paid")
      case params[:price]
      when "Free"
        { :with => {:price => 0 } }
      when "Paid"
        { :without => {:price => 0} }
      end
    end
  end
  def items_by_owner(params)
    { :with => {:user_id => params[:current_user_id] } }
  end
end