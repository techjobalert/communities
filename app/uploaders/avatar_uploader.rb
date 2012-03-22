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

  process :manualcrop, :if => :cropping?
  process :resize_to_fit => [800, 600], :if => :not_cropping?

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

  def manualcrop
    return unless model.cropping?
    manipulate! do |img|
      img.crop("#{model.crop_w}x#{model.crop_h}+#{model.crop_x}+#{model.crop_y}")
      img = yield(img) if block_given?
      img
    end
  end

  def cropping? picture
    model.cropping?
  end

  def not_cropping? picture
    not model.cropping?
  end

end
