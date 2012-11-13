class CreateDocumentDetails < ActiveRecord::Migration
  def change
    create_table :document_details do |t|
      t.integer :attachment_id
      t.integer :page_count
      t.integer :page_width
      t.integer :page_height

      t.timestamps
    end
  end
end
