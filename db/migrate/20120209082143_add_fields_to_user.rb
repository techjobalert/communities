class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :full_name, :string

    add_column :users, :profession_and_degree, :string

  end
end
