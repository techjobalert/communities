class PasswordsController < Devise::PasswordsController
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => root_path)
    else
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
      redirect_to root_path
    end
  end
end