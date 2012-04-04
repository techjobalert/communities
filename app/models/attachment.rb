class Attachment < ActiveRecord::Base
  belongs_to :item #, :counter_cache => true
  belongs_to :user #, :counter_cache => true
  has_many   :attachment_previews, :dependent => :destroy

  attr_accessible :user, :file

  # validates_presence_of :user

  #File upload
  mount_uploader        :file, FileUploader
  process_in_background :file
  store_in_background   :file

  def extension_is?(exts)
    dot_exts = []
    dot_exts << exts if exts.is_a? String
    dot_exts = exts.map!{ |e| "."+e } if exts.is_a? Array
    dot_exts.member? File.extname(file.path) unless dot_exts.blank? and file.nil?
  end

  def is_pdf?
    file.present? and extension_is?("pdf")
  end

  def is_video?
    file.present? and extension_is?("mp4")
  end

  def is_processed_to_mp4?
    not file.mp4.nil? and extension_is?(%w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi))
  end

  def is_processed_to_pdf?
    not file.pdf.nil? and extension_is?(["doc","docx"])
  end

  def get_thumbnail
    if self.is_pdf?
      self.file.pdf_thumbnail.url
    else
      self.file.video_thumbnail.url
    end
  end

end
