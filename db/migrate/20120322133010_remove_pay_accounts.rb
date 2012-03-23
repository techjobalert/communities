class RemovePayAccounts < ActiveRecord::Migration
  def up
    drop_table :pay_accounts
  end

  def down
  end
end
