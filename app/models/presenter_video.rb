class PresenterVideo < ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  attr_accessible :user, :file, :item

  #File upload
  mount_uploader        :file, PresenterVideoUploader
  process_in_background :file
  store_in_background   :file

end
