class CreateCommunityItems < ActiveRecord::Migration
  def change
    create_table :community_items do |t|
      t.belongs_to :community
      t.belongs_to :item

      t.timestamps
    end
    add_index :community_items, :community_id
    add_index :community_items, :item_id
  end
end
