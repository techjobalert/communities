class OmniauthCallbacksController <  Devise::OmniauthCallbacksController
  def google_oauth2
    # You need to implement the method below in your model
    access_token = request.env["omniauth.auth"]
    logger.info "--------------access_token-------------#{access_token.inspect}"
    if user_signed_in? && current_user
      if current_user.social_account_credential 
      	current_user.social_account_credential.update_attributes(:google_token => access_token.credentials.token, :google_user_id => access_token.uid)
      elsif	 
      	(current_user.create_social_account_credential(:google_token => access_token.credentials.token, :google_user_id => access_token.uid))
     	end
    end
    redirect_to root_path
  end
end
