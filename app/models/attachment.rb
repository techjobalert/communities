class Attachment < ActiveRecord::Base

  belongs_to :item #, :counter_cache => true
  belongs_to :user #, :counter_cache => true
  has_many   :attachment_previews, :dependent => :destroy
  has_many   :pdf_images, :dependent => :destroy
  has_one    :document_detail, :dependent => :destroy

  attr_accessible :user, :file, :item_id, :attachment_type, :user_id, :file_processing
  store :video_timing, accessors: [ :playback_points ]
  # validates_presence_of :user

  #File upload


  mount_uploader        :file, FileUploader
  process_in_background :file
  store_in_background   :file

  before_save     :set_type
  before_save     :remove_prev_version
  before_destroy  :destroy_attachments
  after_save :send_notification_mail, :if => :asset_uploaded?
  after_save :update_preview, :if => :asset_uploaded?
  # after_save :create_preview, :if => :file_processing_changed?

  # def create_preview
  #   if attachment_type == "regular" and file_processing == nil
  #     # item.attachments.where(:attachment_type => "video_preview").destroy_all
  #     Resque.enqueue(CreatePreview, self.item.id, self.item.preview_length)
  #   end
  # end

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
    if type && (self.attachment_type != "presenter_merged_video")
      #self.attachment_type = type if self.attachment_type == "regular"
      item.update_attribute(:attachment_type, type)
    end
  end

  def remove_prev_version
    if file
      item.attachments.where(:attachment_type => self.attachment_type).where('id != ?', id).destroy_all
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

  def get_imgs
    if self.pdf_images.present?
      directory = File.dirname(self.pdf_images.first.file.url)
      directory = File.dirname(directory)
      "#{directory}/{page}/page.png"
    else
      nil
    end
  end

  # def is_video?
  #   file.present? and extension_is?("mp4")
  # end

  def is_processed_to_video?
    extension_is?(%w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v))
  end

  def is_presentation?
    presentation_types = %w(presentation_video merged_presentation_video presenter_merged_video presentation_video_preview)
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

  private

  def send_notification_mail
    if self.item.processed? && self.item.state == "moderated" && attachment_type == "regular"
      Resque.enqueue(SendProcessedMessage, self.item_id)
    end
  end

  def update_preview
    if attachment_type == "regular"
      previews = self.item.attachments.where(:attachment_type => "video_preview").destroy_all
      if self.item.preview_length > 0
        Resque.enqueue(CreatePreview, self.item.id, self.item.preview_length)
      end
    end
  end

  def asset_uploaded?
    file_tmp_changed? && file_changed? && file_processing_changed? && !created_at_changed?
  end

end
