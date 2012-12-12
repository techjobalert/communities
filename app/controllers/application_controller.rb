class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    @notice = {:type => 'error', :message => exception.message}
    respond_to do |format|
      format.html { redirect_to root_path, :notice => exception.message }
      format.js { render :partial => "layouts/access_denied", :locals => {:notice => @notice} }
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def after_sign_in_path_for(resource)
    root_path
  end


end
