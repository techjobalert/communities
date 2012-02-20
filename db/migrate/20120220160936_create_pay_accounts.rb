class CreatePayAccounts < ActiveRecord::Migration
  def change
    create_table :pay_accounts do |t|
      t.string :first_name
      t.string :last_name
      t.string :verification_value
      t.string :year
      t.string :month
      t.string :number
      t.string :type
      t.references :user
      t.boolean :active, :default => false

      t.timestamps
    end
    add_index :pay_accounts, :user_id
  end
end
