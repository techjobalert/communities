class CreateSocialAccountCredentials < ActiveRecord::Migration
  def change
    create_table :social_account_credentials do |t|
      t.integer :user_id
      t.string :google_token
      t.string :google_user_id

      t.timestamps
    end
  end
end
