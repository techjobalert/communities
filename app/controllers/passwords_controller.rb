class PasswordsController < Devise::PasswordsController
  def create
    raise 'error'

    if successfully_sent?(resource)
      respond_with({}, :location => root_path)
    else
      flash[:notice] = I18n.t("devise.passwords.send_instructions")
      redirect_to root_path
    end
  end
end