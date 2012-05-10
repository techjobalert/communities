class AddDeltaToItems < ActiveRecord::Migration
  def change
    add_column :items, :delta, :boolean, :default => true, :null => false

  end
end
