module CommunitiesHelper
  def current_community?
    current_community = session[:community].try(:name)
    current_community && current_community == @community.try(:name)
  end
end