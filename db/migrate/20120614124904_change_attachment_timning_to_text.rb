class ChangeAttachmentTimningToText < ActiveRecord::Migration
  def up
    change_column :attachments, :timing, :text
  end

  def down
    change_column :attachments, :timing, :string
  end
end
