class AddItemIdAndUserIdToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :item_id, :integer

    add_column :attachments, :user_id, :integer

  end
end
