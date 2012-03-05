class SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers
  
  def create
    Rails.logger.info "===================== #{session.inspect} ============================="

    session[:failure_counter].present? ? (session[:failure_counter] += 1) : session[:failure_counter] = 1
    
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

end