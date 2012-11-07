module CarrierWave
  module Uploader
    module Versions
      def recreate_version!(version)
        already_cached = cached?
        cache_stored_file! if !already_cached
        send(version).store!
        if !already_cached && @cache_id
          tmp_dir = File.expand_path(File.join(cache_dir, cache_id), CarrierWave.root)
          FileUtils.rm_rf(tmp_dir)
        end
      end
    end
  end
end

module CarrierWave
  module MiniMagick

    # Rotates the image based on the EXIF Orientation
    def fix_exif_rotation
      manipulate! do |img|
        img.auto_orient!
        img = yield(img) if block_given?
        img
      end
    end

  end
end
