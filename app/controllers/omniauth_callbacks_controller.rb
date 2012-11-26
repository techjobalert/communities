class OmniauthCallbacksController <  Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model
    access_token = request.env["omniauth.auth"]
    if user_signed_in? && current_user
      if current_user.social_account_credential
      	current_user.social_account_credential.update_attributes(
          :google_token => access_token.credentials.token,
          :google_user_id => access_token.uid,
          :google_refresh_token => access_token.credentials.refresh_token
        )
      else
      	current_user.create_social_account_credential(
          :google_token => access_token.credentials.token,
          :google_user_id => access_token.uid,
          :google_refresh_token => access_token.credentials.refresh_token
        )
     	end
    end
    render :nothing => true
  end
end
