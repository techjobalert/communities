class AddApprovedByToItems < ActiveRecord::Migration
  def change
    add_column :items, :approved_by, :integer

  end
end
