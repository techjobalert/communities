class AddViewsCountToItems < ActiveRecord::Migration
  def change
    add_column :items, :views_count, :integer

  end
end