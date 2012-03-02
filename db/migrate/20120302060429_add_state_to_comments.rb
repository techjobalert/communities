class AddStateToComments < ActiveRecord::Migration
  def change
    add_column :comments, :state, :string, :default => "moderated"
  end
end
