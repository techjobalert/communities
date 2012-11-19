require 'streamio-ffmpeg'
module CarrierWave
  module FFMPEG
    extend ActiveSupport::Concern

    module ClassMethods
      def convert_to_mp4 options
        process :convert_to_mp4 => options
      end

      def convert_to_webm options
        process :convert_to_webm => options
      end

      def hb_convert_to_mp4 options
        process :hb_convert_to_mp4 => options
      end

      def hb_mobile_convert_to_mp4 options
        process :hb_mobile_convert_to_mp4 => options
      end

      def create_video_thumbnail options
        process :create_video_thumbnail => options
      end
    end

    def hb_convert_to_mp4
      tmp_path = uuid_name(current_path)
      mp4_tmp_path = tmp_path+".mp4"
      presentation_settings = '-e x264  -q 20.0 -a none -E faac,copy:ac3 -B 160,160 -6 dpl2,auto -R Auto,Auto -D 0.0,0.0 -f mp4 -X 720 --loose-anamorphic -m -x cabac=0:ref=2:me=umh:bframes=0:weightp=0:8x8dct=0:trellis=0:subme=6'
      empty_audio_track = ::FFMPEG::Movie.new(tmp_path).audio_stream.nil?
      %x[HandBrakeCLI -i #{tmp_path} #{empty_audio_track ? presentation_settings : '-Z Universal'} -O -I -m -o #{mp4_tmp_path}]
      File.delete( tmp_path )
      File.rename mp4_tmp_path, current_path
    end

    def hb_mobile_convert_to_mp4
      tmp_path = uuid_name(current_path, false)
      %x[HandBrakeCLI -Z Universal -i #{current_path} -o #{tmp_path} -e x264 -b 650 -T -2 -O -I -f mp4 -r 29.97 -a 1 -E faac -B 64 -6 dpl2 -R 48 -D 0.0 -f mp4 -X 480 -m -x cabac=0:ref=5:me=umh:bframes=0:subme=6:8x8dct=0:trellis=0:analyse=all]
      File.rename tmp_path, current_path
    end

    def convert_to_webm *args
      convert_to(".webm", *args)
    end

    def convert_to_mp4 *args
      convert_to(".mp4", *args)
    end

    def create_video_thumbnail(h="00",m="00",s="01.0")
      
      Resque.enqueue(CreatePreview, model.item.id, model.item.preview_length)

      tmp  = current_path+".jpeg"
      path = File.absolute_path(current_path)
      file = ::FFMPEG::Movie.new(path)
      file.transcode(tmp, :custom => "-ss #{h}:#{m}:#{s} -s 435x264 -vframes 1 -f image2")
      File.rename tmp, current_path
      self.file.instance_variable_set(:@content_type, "image/jpeg")
      model.file_processing = nil
      
      if file
        #if %w(presenter_merged_video regular presentation_video).member? model.attachment_type
        #  Resque.enqueue(SendProcessedMessage, model.item.id)
        #end
        # remove source file
        Resque.enqueue(RemoveSourceFile, model.file.path)
        # remove parent source file
        parent_attachment_source_path = model.item.attachments.where({attachment_type: "presentation_video"}).last
        Resque.enqueue(RemoveSourceFile, parent_attachment_source_path.file.path) if parent_attachment_source_path
      end

      

    end

    private
    def uuid_name current_path, rename_parent=true
      directory = File.dirname( current_path )
      tmp_file  = ["tmpfile", SecureRandom.uuid].join("-")+File.extname(current_path)
      tmp_path  = File.join( directory, tmp_file )
      File.rename current_path, tmp_path if rename_parent
      tmp_path
    end

    def convert_to format, *args
      options = args.inject({}){|o, p| o[p.first] = p.last; o } # combining hash from array of pairs
      tmp_path = uuid_name(current_path)

      file = ::FFMPEG::Movie.new(tmp_path)
      tmp_webm = tmp_path+format
      options[:audio_bitrate] = 32 if File.extname(current_path) == ".3gp"
      file.transcode(tmp_webm , options)

      File.rename tmp_webm, current_path
      case format
        when ".mp4"
          self.file.instance_variable_set(:@content_type, "video/mp4")
        when ".webm"  
          self.file.instance_variable_set(:@content_type, "video/webm")
      end
      File.delete( tmp_path )
    end
  end
end
