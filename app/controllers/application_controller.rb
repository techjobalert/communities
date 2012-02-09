class ApplicationController < ActionController::Base
  # before_filter :authenticate
  protect_from_forgery
  
  #before_filter :authenticate_user!
    
  protected
  # def authenticate
  #   authenticate_or_request_with_http_basic do |username, password|
  #     username == "foo" && password == "bar"
  #   end
  # end

end
