class ChangePriceInItems < ActiveRecord::Migration
  def up
    change_column :items, :price, :float, :null => false
  end

  def down
    change_column :items, :price, :float, :null => true
  end
end
