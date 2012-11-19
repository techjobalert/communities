class SocialAccountCredential < ActiveRecord::Base


	belongs_to :user


  attr_accessible :google_token, :google_user_id, :user_id
end
