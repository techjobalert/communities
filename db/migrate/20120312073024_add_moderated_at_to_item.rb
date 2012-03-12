class AddModeratedAtToItem < ActiveRecord::Migration
  def change
    add_column :items, :moderated_at, :datetime
  end
end
