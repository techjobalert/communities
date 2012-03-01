class SearchController < ApplicationController
  include SettingsHelper

  def index
    @search_params = SearchParams.new(params)
    per_page = get_setting("show_search_results_per_page")
    @search_results = @search_params.get_search_results.page(params[:page]).per(per_page)
  end

  def qsearch
    @search_params = SearchParams.new({
      SearchParams.query_param => params[:term],
      SearchParams.page_param => 1,
      SearchParams.per_page_param => 5
    })

    @search_results = @search_params.get_search_results || []
    @search_results.map! do |item|
      if item.is_a? User do
        {
          :title => item.full_name.truncate(40, :separator => ' '),
          :content => item.bio.truncate(50, :separator => ' '),
          :url => polymorphic_path(item)
        }
      elsif item.is_a? Item do
        {
          :title => item.title.truncate(40, :separator => ' '),
          :content => item.description.truncate(50, :separator => ' '),
          :url => polymorphic_path(item)
        }
      end
    end
    render :json => @search_results
  end

  private

  def path_to_founded_item(item)
    case
      when item.instance_of?(Idea)
        url_for([item.challenge, item])
      when item.instance_of?(Challenge)
        url_for([item])
      else
        polymorphic_path(item)
    end
  end

end
