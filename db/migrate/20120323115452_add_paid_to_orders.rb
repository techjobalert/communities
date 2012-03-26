class AddPaidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :purchased, :boolean, :default => 0

  end
end
