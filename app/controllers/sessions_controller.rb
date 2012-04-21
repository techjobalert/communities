class SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers

  def create
    failure_counter = $redis.get(session[:session_id])
    failure_counter = (failure_counter.to_i || 0) + 1
    $redis.set(session[:session_id], failure_counter)

    if failure_counter <= 3 || simple_captcha_valid?
      resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource)
      $redis.del(session[:session_id])
      redirect_to root_path
    else
      build_resource
      clean_up_passwords(resource)
      flash[:alert] = "There was an error with the captcha code below. Please re-enter the code."
      redirect_to "#{root_path}#sign-in"
    end
  end

  protected

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end

end