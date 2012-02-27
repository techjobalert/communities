class AddDeletedAndAmountToItem < ActiveRecord::Migration
  def change
    add_column :items, :deleted, :boolean, :default => false

    add_column :items, :amount, :float, :default => 0

  end
end
