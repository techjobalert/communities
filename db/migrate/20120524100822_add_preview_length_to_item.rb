class AddPreviewLengthToItem < ActiveRecord::Migration
  def change
    add_column :items, :preview_length, :integer, :default => 0
  end
end
