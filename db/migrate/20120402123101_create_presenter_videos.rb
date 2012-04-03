class CreatePresenterVideos < ActiveRecord::Migration
  def change
    create_table :presenter_videos do |t|
      t.references :user
      t.references :item
      t.string :file
      t.string :file_tmp
      t.boolean :file_processing
      t.string :type
      t.string :state

      t.timestamps
    end
    add_index :presenter_videos, :user_id
    add_index :presenter_videos, :item_id
  end
end
