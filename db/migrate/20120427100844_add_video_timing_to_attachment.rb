class AddVideoTimingToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :video_timing, :string
  end
end
