class RemovePublishedAndDeletedFromItems < ActiveRecord::Migration
  def up
    remove_column :items, :published
    remove_column :items, :deleted
  end

  def down
    add_column :items, :published, :boolean
    add_column :items, :deleted, :boolean
  end
end
