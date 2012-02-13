class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_in_path_for(resource_or_scope)	
    # if session[:registered_from] == projects_register_path
    #   new_project_path
    # else
    #   account_index_path
    # end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
  
end
