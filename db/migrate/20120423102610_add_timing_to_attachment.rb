class AddTimingToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :timing, :string
  end
end
