# encoding: utf-8
require File.join(Rails.root, "lib", "ffmpeg")

class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::RMagick
  include CarrierWave::FFMPEG
  include ::CarrierWave::Backgrounder::DelayStorage
  # include CarrierWave::MimeTypes
  # process :set_content_type

  version :pdf,                 :if => :is_document?
  version :pdf_thumbnail,       :if => :is_pdf?

  version :webm,                :if => :is_video?
  version :mobile,              :if => :is_video?
  version :video_thumbnail,     :if => :is_video?

  def default_url
    "/default/item_" + [version_name, "default.png"].compact.join('_')
  end

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf doc docx key 3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v)
  end

  version :pdf do
    process :convert_to_pdf
    def full_filename (for_file = model.file.file)
      "document_#{File.basename(for_file, File.extname(for_file))}.pdf"
    end
  end

  version :pdf_thumbnail do
    process :create_pdf_thumbnail
    def full_filename (for_file = model.file.file)
      "thumb_#{File.basename(for_file, File.extname(for_file))}.jpeg"
    end
  end

  # version :mp4 do
  #   process :hb_convert_to_mp4
  #   def full_filename (for_file = model.file.file)
  #     "mp4_#{File.basename(for_file, File.extname(for_file))}.mp4"
  #   end
  # end
  # version :mobile, :from_version => :mp4 do
  #   process :hb_mobile_convert_to_mp4
  #   def full_filename (for_file = model.file.file)
  #     "mobile_#{File.basename(for_file, File.extname(for_file))}.mp4"
  #   end
  # end

  version :webm do
    process :convert_to_webm => {
              :audio_codec => 'libvorbis',
              :video_codec => 'libvpx',
              :threads => 1,
              :custom => "-quality good -cpu-used 0 -b:v 500k -qmin 10 -qmax 42 -maxrate 500k -bufsize 1000k -b:a 128k -r 23.976"
            }
    def full_filename (for_file = model.file.file)
      "webm_#{File.basename(for_file, File.extname(for_file))}.webm"
    end
  end

  version :mobile, :from_version => :webm do
    process :convert_to_webm => {
          :threads => 1,
          :custom => "-vf scale=-1:360"
        }
    def full_filename (for_file = model.file.file)
      "mobile_#{File.basename(for_file, File.extname(for_file))}.webm"
    end
  end

  version :video_thumbnail, :from_version => :webm do
    process :create_video_thumbnail
    def full_filename (for_file = model.file.file)
      "thumb_#{File.basename(for_file, File.extname(for_file))}.jpeg"
    end
  end

  protected

  def convert_to_pdf
    # move upload to local cache
    cache_stored_file! if !cached?

    directory = File.dirname( current_path )
    # move upload to tmp file - encoding result will be saved to
    # original file name
    tmp_path   = File.join( directory, "tmpfile"+File.extname(current_path) )
    File.rename current_path, tmp_path

    # encode
    command =%x[libreoffice --headless -convert-to pdf #{tmp_path} -outdir #{directory}]
    fixed_name = File.basename(tmp_path, '.*') + "." + "pdf"
    File.rename File.join( directory, fixed_name ), current_path

    # delete tmp file
    File.delete tmp_path
  end

  def create_pdf_thumbnail
    # move upload to local cache
    cache_stored_file! if !cached?

    directory = File.dirname( current_path )
    image_path = File.join( directory, "tmp.jpeg")
    path = model.file.pdf.path.nil? ? current_path : File.absolute_path(model.file.pdf.path)

    pdf = Magick::ImageList.new(path).first
    thumb = pdf.scale(265, 200)
    thumb.write image_path

    File.delete current_path
    File.rename image_path, current_path
    Resque.enqueue(SendProcessedMessage, model.id) if file
    model.file_processing = nil
  end

  def merge_presenter_video
    tmp  = current_path+".jpeg"
    path = File.absolute_path(current_path)
    file = ::FFMPEG::Movie.new(path)
    file.transcode(tmp, :custom => "-ss #{h}:#{m}:#{s} -s 435x264 -vframes 1 -f image2")
    File.rename tmp, current_path
    Resque.enqueue(SendProcessedMessage, model.id) if file
    model.file_processing = nil
  end

  def is_video? f
    exts = %w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v).map!{|e| "."+ e }
    exts.member? File.extname(f.file)
  end

  def is_pdf? f
    [".pdf", ".doc", ".docx"].member? File.extname(f.file)
  end

  def is_document? f
    [".doc", ".docx"].member? File.extname(f.file) #or model.is_pdf?
  end

end
