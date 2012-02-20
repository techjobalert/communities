class DropAuthor < ActiveRecord::Migration
  def up
    drop_table :authors
  end
end
