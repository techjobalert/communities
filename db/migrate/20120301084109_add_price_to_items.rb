class AddPriceToItems < ActiveRecord::Migration
  def change
    add_column :items, :price, :float, :default => 0

  end
end
