# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    "/assets/default/user_" + [version_name, "default.png"].compact.join('_')
  end

  #  def default_url
  #    "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  #  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb_143 do
     process :resize_to_fill => [143, 143]
  end

  version :thumb_70 do
     process :resize_to_fill => [70, 70]
  end

  version :thumb_60 do
     process :resize_to_fill => [60, 60]
  end

  version :thumb_45 do
     process :resize_to_fill => [45, 45]
  end

  def extension_white_list
     %w(jpg jpeg png JPG JPEG PNG)
  end

end
