require 'streamio-ffmpeg'
module CarrierWave
  module FFMPEG
    extend ActiveSupport::Concern

    module ClassMethods
      def convert_to_mp4 options
        process :convert_to_mp4 => options
      end
      def create_video_thumbnail options
        process :create_video_thumbnail => options
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

    def create_video_thumbnail(h="00",m="00",s="03.0")
      cache_stored_file! if !cached?

      # args = [h,m,s]
      # args.each_with_index do |t, index|
      #   if index != 0 and d = t.div(60)
      #     t = t-d*60
      #     args[index-1] = args[index-1]+d
      #   end
      #   t = "0"+t.to_s if t < 10
      # end
      tmp  = current_path+".jpeg"
      path = File.absolute_path(current_path)
      file = ::FFMPEG::Movie.new(path)
      t = Time.at(file.duration/2)
      file.transcode(tmp, :custom => "-ss #{h}:#{m}:#{s} -s 435x264 -vframes 1 -f image2")
      File.rename tmp, current_path
      Resque.enqueue(SendProcessedMessage, model.id) if file
    end

  end
end