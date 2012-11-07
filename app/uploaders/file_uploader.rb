# encoding: utf-8
require File.join(Rails.root, "lib", "ffmpeg")
require 'RMagick'

class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::RMagick
  include CarrierWave::FFMPEG
  include ::CarrierWave::Backgrounder::DelayStorage
  # include CarrierWave::MimeTypes
 

  # documents
  version :pdf,                 :if => :is_document?
  version :pdf_thumbnail,       :if => :is_pdf?
  version :pdf_json,            :if => :is_pdf?

  # video
  version :mp4,                 :if => :is_video?
  version :mobile,              :if => :is_video?
  version :webm,                :if => :is_video?
  version :video_thumbnail,     :if => :is_video?


  after :store, :upload_to_s3
  # presentation_video
  #version :presentation_video,  :if => :is_presentation?
  

  def default_url
    "/default/item_" + [version_name, "default.png"].compact.join('_')
  end

  storage :fog

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf doc docx key ppt pptx 3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v)
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
      "thumb_#{File.basename(for_file, File.extname(for_file))}.png"
    end
  end

  version :pdf_json do
    process :create_pdf_json
    def full_filename (for_file = model.file.file)
      "json_#{File.basename(for_file, File.extname(for_file))}.js"
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

  version :mp4 do
    process :convert_to_mp4 => {
              :threads => 1,
              :custom => "-acodec libfaac -ab 128k -ac 2 -vcodec libx264 -crf 22"
    }
    def full_filename (for_file = model.file.file)
      "mp4_#{File.basename(for_file, File.extname(for_file))}.mp4"
    end
  end

  version :webm do
    process :convert_to_webm => {
              :audio_codec => 'libvorbis',
              :video_codec => 'libvpx',
              :audio_bitrate => '128',
              :threads => 1,
              :custom => "-quality good -b:v 500k -qmin 10 -qmax 42 \
                          -maxrate 500k -bufsize 1000k -vpre libvpx-720p"
            }      
    def full_filename (for_file = model.file.file)
      "webm_#{File.basename(for_file, File.extname(for_file))}.webm"
    end
  end

  version :mobile, :from_version => :mp4 do
    process :convert_to_mp4 => {
              :threads => 1,
              :custom => "-acodec libfaac -aq 100 -ac 2 -vcodec libx264 \
                          -vpre libx264-ipod640 -async 1"
    }
    def full_filename (for_file = model.file.file)
      "mobile_#{File.basename(for_file, File.extname(for_file))}.mp4"
    end
  end

  version :video_thumbnail, :from_version => :mp4 do
    process :create_video_thumbnail
    def full_filename (for_file = model.file.file)
      "thumb_#{File.basename(for_file, File.extname(for_file))}.jpeg"
    end
  end

  # version :presentation_video do
  #   process :convert_to_video
  # end

  

  def upload_to_s3(file)
    if [".pptx", ".key"].member?(File.extname(current_path))
      uuid_filename = [SecureRandom.uuid, File.basename(current_path)].join("-")
      Resque.enqueue(PowerPointConvert, File.extname(current_path),uuid_filename, current_path, model.id)
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

    full_pdf_path = File.join( directory, fixed_name )
    File.rename full_pdf_path, current_path

    # delete tmp file
    File.delete tmp_path
    self.file.instance_variable_set(:@content_type, "appliaction/pdf")
  end

  def create_pdf_thumbnail
    # move upload to local cache
    
    cache_stored_file! if !cached?

    directory = File.dirname( current_path )
    image_path = File.join( directory, "tmp.png")
    path = model.file.pdf.path.nil? ? current_path : File.absolute_path(model.file.pdf.path)
    
    
    pdf = Magick::ImageList.new(path).first
    thumb = pdf.resize_to_fill(265, 200, ::Magick::NorthGravity)
    thumb.write image_path
    
    File.delete current_path
    File.rename image_path, current_path
    self.file.instance_variable_set(:@content_type, "image/png")
    model.file_processing = nil
  end

  def create_pdf_flash
    
    cache_stored_file! if !cached?
    
    directory = File.dirname( current_path )
    flash_path = File.join( directory, "tmp.swf")
    path = model.file.pdf.path.nil? ? current_path : File.absolute_path(model.file.pdf.path)
    
    command =%x[pdf2swf #{path} -o #{flash_path} -f -T 9 -t -s storeallcharacters]
    
    File.delete current_path
    File.rename flash_path, current_path
    model.file_processing = nil
  end

  def create_pdf_json
    cache_stored_file! if !cached?
    
    directory = File.dirname( current_path )
    json_path = File.join( directory, "tmp.js")
    path = model.file.pdf.path.nil? ? current_path : File.absolute_path(model.file.pdf.path)
    result = populate_pages_preview_images(path)
    width, height, count = result[0], result[1], result[2]
    images = []
    count.times do |n|
      images << {"number" => n+1, "fonts" => [], "text" => [], "width" => width, "height" => height}
    end
    File.open(json_path,"w") do |f|
      f.write(images.to_json)
    end

    #command =%x[pdf2json -enc UTF-8 -compress #{path} #{json_path}]
    
    File.delete current_path
    File.rename json_path, current_path
    self.file.instance_variable_set(:@content_type, "text/json")
    model.file_processing = nil
  end

  def populate_pages_preview_images(pdf_file_path)
    pdf = Magick::ImageList.new(pdf_file_path) { self.density = 150 }
    pdf_dir_path = File.dirname(pdf_file_path)
    pdf.write("#{pdf_dir_path}/pdf_preview.png")
    all_previews = Dir["#{pdf_dir_path}/*.png"]

    all_previews.sort_by! {|elem| elem.match(/\d+(?=\.png$)/)[0].to_i} if pdf.count > 1

    all_previews.each_with_index do |page_file, page_number|
      model.pdf_images.create!(file: File.open(page_file), page_number: page_number + 1)
      File.delete(page_file)
    end

    [pdf[0].columns,pdf[0].rows,pdf.count]
  end

  def merge_presenter_video
    tmp  = current_path+".jpeg"
    path = File.absolute_path(current_path)
    file = ::FFMPEG::Movie.new(path)
    file.transcode(tmp, :custom => "-ss #{h}:#{m}:#{s} -s 435x264 -vframes 1 -f image2")
    File.rename tmp, current_path
    model.file_processing = nil
  end

  def convert_to_video
    # Save presentation file to shared folder
    # And send req to mac
    cache_stored_file! if !cached?
    file = File.absolute_path(current_path)
    uuid_filename = [SecureRandom.uuid, File.basename(file)].join("-")
   # FileUtils::copy_file(file, "../video/video_storage/p_source/#{uuid_filename}")
    #Resque.enqueue(PowerPointConvert, File.extname(current_path), uuid_filename, model.id)
    Resque.enqueue(PowerPointConvert, File.extname(current_path),uuid_filename, file, model.id)
    #model.file_processing = true
  end

  def is_video? f
    exts = %w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4 m4v).map!{|e| "."+ e }
    if model.attachment_type != "presenter_video"
      exts.member? File.extname(file.path) or (is_presentation?(f) and model.file_processing == nil)
    end
  end

  def is_pdf? f
    [".pdf", ".doc", ".docx"].member? File.extname(file.path)
  end

  def is_document? f
    [".doc", ".docx"].member? File.extname(file.path)
  end

  def is_presentation? f
    [".pptx", ".key"].member? File.extname(file.path)
  end

end
