class SearchController < ApplicationController
  include SettingsHelper

  def index
    @search_params = SearchParams.new(params)
    per_page = get_setting("show_search_results_per_page")
    @search_results = @search_params.get_search_results.page(params[:page]).per(per_page)
  end

def qsearch_item
    @search_results = qsearch_base(params[:term], Item)
    @search_results.map! do |item|
      {
        :title => item.title.truncate(40, :separator => ' '),
        :content => item.description.truncate(50, :separator => ' '),
        :url => polymorphic_path(item)
      }
    end
    render :json => @search_results
  end

  def qsearch_user
    @search_results = qsearch_base(params[:term], User)
    @search_results.map! do |user|
      {
        :full_name => user.full_name.truncate(40, :separator => ' '),
        :content => user.specialization.truncate(50, :separator => ' '),
        :url => polymorphic_path(user)
      }
    end
    render :json => @search_results
  end

  private
  def qsearch_base(term, klasses)
    _params = {
      SearchParams.query_param => term,
      SearchParams.page_param => 1,
      SearchParams.per_page_param => 5
    }
    _params.merge!({:classes => [*klasses]}) if klasses
    search_params = SearchParams.new(_params)
    search_params.get_search_results || []
  end

end
