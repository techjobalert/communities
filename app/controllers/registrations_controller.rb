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
      flash[:error] = resource.errors.full_messages.first
      redirect_to root_path # HERE IS THE PATH YOU WANT TO CHANGE
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(params[resource_name])
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true

      #respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      flash[:error] = resource.errors.full_messages.first
      #respond_with resource
    end
    redirect_to user_path(current_user)
  end

  protected

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end
end
