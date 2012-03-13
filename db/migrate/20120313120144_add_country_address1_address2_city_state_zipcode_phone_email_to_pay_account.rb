class AddCountryAddress1Address2CityStateZipcodePhoneEmailToPayAccount < ActiveRecord::Migration
  def change
    add_column :pay_accounts, :country, :string

    add_column :pay_accounts, :address1, :string

    add_column :pay_accounts, :address2, :string

    add_column :pay_accounts, :city, :string

    add_column :pay_accounts, :state, :string

    add_column :pay_accounts, :zipcode, :string

    add_column :pay_accounts, :phone, :string

    add_column :pay_accounts, :email, :string

  end
end
