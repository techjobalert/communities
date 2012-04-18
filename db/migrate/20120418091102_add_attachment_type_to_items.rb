class AddAttachmentTypeToItems < ActiveRecord::Migration
  def change
    add_column :items, :attachment_type, :string

  end
end
