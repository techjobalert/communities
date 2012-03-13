class AddPurchasedAtToUser < ActiveRecord::Migration
  def change
    add_column :users, :purchased_at, :datetime

  end
end
