class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.references :contributor
      t.references :item

      t.timestamps
    end
    add_index :contributions, :contributor_id
    add_index :contributions, :item_id
  end
end
