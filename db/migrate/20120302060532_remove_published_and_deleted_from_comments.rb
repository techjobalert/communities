class RemovePublishedAndDeletedFromComments < ActiveRecord::Migration
   def up
    remove_column :comments, :published
  end

  def down
    add_column :comments, :published, :boolean
  end
end
