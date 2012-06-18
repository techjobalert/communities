class PasswordsController < Devise::PasswordsController
  def create
    #self.resource = resource_class.send_reset_password_instructions(resource_params) for 2.1.0
    self.resource = resource_class.send_reset_password_instructions(params[resource_name]) # for 2.0.4

    if successfully_sent?(resource)
      respond_with({}, :location => root_path)
    else
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
      redirect_to root_path
    end
  end
end