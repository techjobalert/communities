class CreateAttachmentPreviews < ActiveRecord::Migration
  def change
    create_table :attachment_previews do |t|
      t.references :attachment
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing

      t.timestamps
    end
    add_index :attachment_previews, :attachment_id
  end
end
