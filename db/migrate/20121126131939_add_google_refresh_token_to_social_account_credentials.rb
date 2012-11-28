class AddGoogleRefreshTokenToSocialAccountCredentials < ActiveRecord::Migration
  def change
    add_column :social_account_credentials, :google_refresh_token, :string
  end
end
