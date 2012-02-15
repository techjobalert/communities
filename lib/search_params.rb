class SearchParams

  attr_reader :query, :sort, :page, :per_page

  def initialize(_params)
    p = {self.class.per_page_param => 10}
    p.merge!(_params)
    @query, @sort, @page, @per_page = p[self.class.query_param], p[self.class.sort_param], p[self.class.page_param], p[self.class.per_page_param]
    @sort = nil unless @sort == 'newest' || @sort == 'oldest'
  end

  def get_search_results
    return nil unless @query

    options = {}
    options.merge!(get_sort_options)
    options.merge!(get_paging_options)

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

end