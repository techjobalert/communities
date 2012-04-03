# encoding: utf-8

class PresenterVideoUploader < CarrierWave::Uploader::Base

  version :presentation,        :if => :is_presentation?
  version :mp4,                 :if => :is_video?

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(ppt pptx key 3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi mp4)
  end

  def is_presentation? f
    %w(ppt pptx key).map!{|e| "."+ e }.member? File.extname(f.file)
  end

  def is_video? f
    exts = %w(3gpp 3gp mpeg mpg mpe ogv mov webm flv mng asx asf wmv avi).map!{|e| "."+ e }
    exts.member? File.extname(f.file)
  end

  version :mp4 do
    process :convert_to_mp4 => {
              :audio_codec => 'libfaac',
              :video_codec => 'libx264',
              # :video_preset => 'medium',
              # :custom => "-preset medium"
              # :threads => 4
            }
    def full_filename (for_file = model.file.file)
      "mp4_#{File.basename(for_file, File.extname(for_file))}.mp4"
    end
  end

  version :presentation do
    # process :send_signal_to_convert
  end

  # def send_signal_to_convert
    # FileUtils.mv(current_path, '/opt/new/location/your_file')
    # uri = URI('http://192.168.0.251:3000/convert')
    # Net::HTTP.post_form(uri, 'file' => uuid_filename)
  # end
end
