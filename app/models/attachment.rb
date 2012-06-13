class Attachment < ActiveRecord::Base
  belongs_to :item #, :counter_cache => true
  belongs_to :user #, :counter_cache => true
  has_many   :attachment_previews, :dependent => :destroy

  attr_accessible :user, :file, :item_id, :attachment_type
  store :video_timing, accessors: [ :playback_points ]
  # validates_presence_of :user

  #File upload
  mount_uploader        :file, FileUploader
  process_in_background :file
  store_in_background   :file

  before_save     :set_type
  #before_save     :remove_prev_version
  before_destroy  :destroy_attachments

  def set_type
    type = if is_presentation?
      "presentation"
    elsif self.is_pdf? or self.is_processed_to_pdf?
      "article"
    elsif self.is_processed_to_video?
      "video"
    # else
      # "undefined"
    end
    if type
      #self.attachment_type = type if self.attachment_type == "regular"
      item.update_attribute(:attachment_type, type)
    end
  end

  def remove_prev_version
    if file
      item.attachments.where(:attachment_type => attachment_type).where('id != ?', id).destroy_all
    end
  end

  def destroy_attachments
    if file.path
      FileUtils.rm_rf File.dirname(file.path), :verbose => true
    end
  end

  def extension_is?(exts)
    dot_exts = []
    dot_exts << "."+exts if exts.is_a? String
    dot_exts = exts.map!{ |e| "."+e } if exts.is_a? Array
    f = file_tmp.blank? ? file.path : file_tmp
    if not dot_exts.blank? and f.present?
      dot_exts.member? File.extname(f).downcase
    else
      false
    end
  end

  def is_pdf?
    extension_is?("pdf")
  end

  # def is_video?
  #   file.present? and extension_is?("mp4")
  # end

  def is_processed_to_video?
    extension_is?(%w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v))
  end

  def is_presentation?
    presentation_types = %w(presentation_video merged_presentation_video presentation_video_preview)
    extension_is?(%w(key ppt pptx)) or presentation_types.member? self.attachment_type
  end

  def is_processed_to_pdf?
    extension_is?(%w(doc docx))
  end

  def get_thumbnail
    if self.is_pdf?
      self.file.pdf_thumbnail.url
    else
      self.file.video_thumbnail.url
    end
  end

end
