class AddObjectIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :object_id, :integer

  end
end
