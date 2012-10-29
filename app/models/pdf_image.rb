class PdfImage < ActiveRecord::Base
  attr_accessible :attachment_id, :file, :page_number

  belongs_to :attachment

  mount_uploader :file, PdfImageUploader
  #process_in_background :file
  #store_in_background   :file
end
