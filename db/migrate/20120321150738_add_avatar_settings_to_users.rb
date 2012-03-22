class AddAvatarSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_settings, :string

  end
end
