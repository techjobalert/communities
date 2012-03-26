class CreatePaymentNotifications < ActiveRecord::Migration
  def change
    create_table :payment_notifications do |t|
      t.string :transaction_id
      t.integer :order_id
      t.text :params
      t.string :status

      t.timestamps
    end
  end
end
