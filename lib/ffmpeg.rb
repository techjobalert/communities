require 'streamio-ffmpeg'
module CarrierWave
  module FFMPEG
    extend ActiveSupport::Concern

    module ClassMethods
      def convert_to_mp4 options
        process :convert_to_mp4 => options
      end
    end

    def convert_to_mp4 *args
      options = args.inject({}){|o, p| o[p.first] = p.last; o } # combining hash from array of pairs
      directory = File.dirname( current_path )
      tmp_file  = ["tmpfile", SecureRandom.uuid].join("-")+File.extname(current_path)
      tmp_path  = File.join( directory, tmp_file )

      File.rename current_path, tmp_path

      file = ::FFMPEG::Movie.new(tmp_path)
      tmp_mp4 = tmp_path+".mp4"
      file.transcode(tmp_mp4 , options)
      File.rename tmp_mp4, current_path
      File.delete( tmp_path )

    end

    def create_video_thumbnail(h=0,m=0,s=1)
      cache_stored_file! if !cached?

      args = [h,m,s]
      args.each_with_index do |t, index|
        if index != 0 and d = t.div(60)
          t = t-d*60
          args[index-1] = args[index-1]+d
        end
        t = "0"+t.to_s if t < 10
      end

      directory = File.dirname( current_path )
      path = File.absolute_path(model.file.mp4.path)
      file = ::FFMPEG::Movie.new(path)
      file.transcode(current_path, :custom => "-ss 00:00:01 -vframes 1 -f image2 ")

    end

  end
end