class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :settings, :string

  end
end
