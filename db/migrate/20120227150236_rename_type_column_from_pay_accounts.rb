class RenameTypeColumnFromPayAccounts < ActiveRecord::Migration
  def up
    rename_column :pay_accounts, :type, :payment_type
  end

  def down
    rename_column :pay_accounts, :payment_type, :type
  end
end
