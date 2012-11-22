class OmniauthCallbacksController <  Devise::OmniauthCallbacksController
  before_filter :show_actions
  def google_oauth2
    # You need to implement the method below in your model
    Rails.logger.info "----------#{request.inspect}--------"
    access_token = request.env["omniauth.auth"]
    if user_signed_in? && current_user
      if current_user.social_account_credential 
      	current_user.social_account_credential.update_attributes(:google_token => access_token.credentials.token, :google_user_id => access_token.uid)


        #debug_response = RestClient.get("https://www.googleapis.com/plus/v1/people/#{access_token.uid}/activities/public?alt=json&maxResults=50&&access_token=#{access_token.credentials.token}&key=AIzaSyBB59WRddUJKSwa-7RQvuEMSiMZuTIzj1c")

        #Rails.logger.info "----#{debug_response}----"
      else 
      	current_user.create_social_account_credential(:google_token => access_token.credentials.token, :google_user_id => access_token.uid)
     	end
    end
    redirect_to root_path
  end



  protected

  def show_actions
    Rails.logger.info "----------#{request.inspect}--------"
  end
end
