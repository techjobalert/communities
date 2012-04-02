# encoding: utf-8
require File.join(Rails.root, "lib", "ffmpeg")

class FileUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::RMagick
  include CarrierWave::MimeTypes
  include CarrierWave::FFMPEG
  include ::CarrierWave::Backgrounder::DelayStorage
  process :set_content_type

  version :pdf,                 :if => :is_document?
  version :presentation,        :if => :is_presentation?
  version :mp4,                 :if => :is_video?

  version :pdf do
    process :convert_to_pdf
    def full_filename(for_file = model.file)
      "document_#{File.basename(for_file, File.extname(for_file))}.pdf"
    end
  end
  # version :document_thumbnail do
  #   process :pdf_thumbnail
  #   def full_filename(for_file)
  #     "document_#{File.basename(for_file, File.extname(for_file))}.png"
  #   end
  # end

  version :mp4 do
    process :convert_to_mp4 => {
              :audio_codec => 'libfaac',
              :video_codec => 'libx264',
              # :video_preset => 'medium',
              :custom => "-preset medium"
              # :threads => 4
            }
    def full_filename(for_file = model.file)
      "mp4_#{File.basename(for_file, File.extname(for_file))}.mp4"
    end
  end

  # version :thumbnail do
    # process :create_thumbnail => {} if :is_video?
  # end

  version :presentation do
  end

  protected

  def is_document? f
    [".doc", ".docx"].member? File.extname(f.file)
  end

  def is_presentation? f

  end

  def is_video? f
    exts = %w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi).map!{|e| "."+ e }
    exts.member? File.extname(f.file)
  end

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(pdf doc docx key 3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi)
  end

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

  # def pdf_thumbnail
  #   cache_stored_file! if !cached?
  #   pdf = Magick::ImageList.new(current_path)
  #   thumb = pdf.scale(265, 200)
  #   thumb.write current_path
  # end

end
