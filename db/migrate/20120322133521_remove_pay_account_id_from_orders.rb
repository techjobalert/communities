class RemovePayAccountIdFromOrders < ActiveRecord::Migration
  def up
    remove_column :orders, :pay_account_id
  end

  def down
  end
end
