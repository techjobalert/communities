class DropPaymentNotifications < ActiveRecord::Migration
  def up
    drop_table :payment_notifications
  end

  def down
  end
end
