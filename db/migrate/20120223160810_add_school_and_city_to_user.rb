class AddSchoolAndCityToUser < ActiveRecord::Migration
  def change
    add_column :users, :school, :string

    add_column :users, :city, :string

  end
end
