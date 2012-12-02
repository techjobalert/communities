class AddSubdomainToCommunity < ActiveRecord::Migration
  def change
    add_column :communities, :subdomain, :string
  end
end
