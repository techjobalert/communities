class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    @notice = {:type => 'error', :message => exception.message}
    render :partial => "layouts/access_denied", :locals => {:notice => @notice}
    # redirect_to root_url, :notice => exception.message
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end

end
