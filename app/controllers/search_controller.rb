class SearchController < ApplicationController

  def index
    @search_params = SearchParams.new(params)
    @per_page ||= get_setting("show_search_results_per_page")
    @search_results = @search_params.get_search_results.page(params[:page]).per(@per_page)
    @count ||= @search_params.get_search_results.count
  end

  def qsearch
    @search_params = SearchParams.new({
      SearchParams.query_param => params[:term],
      SearchParams.page_param => 1,
      SearchParams.per_page_param => 5
    })
    @search_results = @search_params.get_search_results || []
    @search_results.map! do |item|
      {
        :title => item.title.truncate(40, :separator => ' '),
        :content => item.description.truncate(50, :separator => ' '),
        :url => path_to_founded_item(item)
      }
    end
    render :json => @search_results
  end
end
