class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :authenticate
  
  def new
    super # no customization, simply call the devise implementation
  end

  def create
    build_resource
    if not resource.save
      clean_up_passwords resource
      respond_with :root
    else
      begin
        super # this calls Devise::RegistrationsController#create
      rescue Orthodontic::Error => e
        e.errors.each { |error| resource.errors.add :base, error }
        clean_up_passwords(resource)
        respond_with_navigational(resource) { render_with_scope :new }
      end
    end
  end

  def update
    super # no customization, simply call the devise implementation 
  end

  protected

  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
