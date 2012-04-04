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
      tmp_st_mp4 = tmp_path+"st_.mp4"
      file.transcode(tmp_mp4 , options)
      p "running qt-faststart"
      command = %x[qt-faststart #{tmp_mp4} #{tmp_st_mp4}]
      File.rename tmp_st_mp4, current_path
      File.delete( tmp_path )
      File.delete( tmp_mp4 )
    end
  end
end