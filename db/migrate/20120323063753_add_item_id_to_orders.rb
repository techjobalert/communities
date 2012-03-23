class AddItemIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :item_id, :integer

  end
end
