class RegistrationsController < Devise::RegistrationsController

  def new
    super # no customization, simply call the devise implementation
  end

def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => redirect_location(resource_name, resource)
      else
        set_flash_message :notice, :signed_up_but_unconfirmed, :reason => resource.inactive_message.to_s if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      # Solution for displaying Devise errors on the homepage found on:
      # http://stackoverflow.com/questions/4101641/rails-devise-handling-devise-error-messages
      flash[:error] = flash[:error].to_a.concat resource.errors.full_messages
      redirect_to root_path # HERE IS THE PATH YOU WANT TO CHANGE
    end
  end

  def update
    super # no customization, simply call the devise implementation
  end

  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end
end
