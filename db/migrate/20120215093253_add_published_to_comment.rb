class AddPublishedToComment < ActiveRecord::Migration
  def change
    add_column :comments, :published, :boolean, :default => false
  end
end
