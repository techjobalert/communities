class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.integer :pay_account_id
      t.string :ip_address

      t.timestamps
    end
  end
end
