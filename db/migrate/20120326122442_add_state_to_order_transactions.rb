class AddStateToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :state, :string

  end
end
