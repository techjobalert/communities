class AddNumberOfUpdatesToItems < ActiveRecord::Migration
  def change
    add_column :items, :number_of_updates, :integer, :default => 0

  end
end
