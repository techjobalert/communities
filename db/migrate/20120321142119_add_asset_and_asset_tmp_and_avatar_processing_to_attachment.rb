class AddAssetAndAssetTmpAndAvatarProcessingToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :file, :string

    add_column :attachments, :file_tmp, :string

    add_column :attachments, :file_processing, :boolean

  end
end
