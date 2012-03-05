class SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers
  before_filter :set_cache_buster

  def create
    session[:failure_counter].present? ? (session[:failure_counter] += 1) : session[:failure_counter] = 1

    Rails.logger.info "=======================#{session[:failure_counter].inspect}======================"
    
    if session[:failure_counter] <= 3 || simple_captcha_valid?      
      resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?      
      sign_in(resource_name, resource)
      #session[:failure_counter] = 0 if user_signed_in?
      redirect_to root_path
    else
      build_resource
      clean_up_passwords(resource)
      flash.delete :recaptcha_error
      flash[:alert] = "There was an error with the captcha code below. Please re-enter the code."
      redirect_to "#{root_path}#sign-in"
    end
  end

  protected

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end