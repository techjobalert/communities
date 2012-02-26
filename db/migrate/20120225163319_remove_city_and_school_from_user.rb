class RemoveCityAndSchoolFromUser < ActiveRecord::Migration
  def up
  	remove_column :users, :school
  	remove_column :users, :city
  end

  def down
	add_column :users, :school, :string
    add_column :users, :city, :string
  end
end
