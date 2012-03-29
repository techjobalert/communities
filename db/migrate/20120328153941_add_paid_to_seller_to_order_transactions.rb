class AddPaidToSellerToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :paid_to_seller, :integer

  end
end
