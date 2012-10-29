class CreatePdfImages < ActiveRecord::Migration
  def change
    create_table :pdf_images do |t|
      t.string :file
      t.integer :attachment_id
      t.integer :page_number

      t.timestamps
    end
  end
end
