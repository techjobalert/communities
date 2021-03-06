class AttachmentPreview < ActiveRecord::Base
  belongs_to :attachment

  attr_accessible :file

  #File upload
  mount_uploader        :file, PreviewUploader
  process_in_background :file
  store_in_background   :file

end
