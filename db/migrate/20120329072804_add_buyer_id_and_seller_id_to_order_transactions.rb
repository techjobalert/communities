class AddBuyerIdAndSellerIdToOrderTransactions < ActiveRecord::Migration
  def change
    add_column :order_transactions, :buyer_id, :integer

    add_column :order_transactions, :seller_id, :integer

  end
end
