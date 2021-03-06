class ProcessPresentationVideo
  @queue = :store_asset

  def self.perform(present_attachment_id, recorded_attachment_id, params)
    present_attachment = Attachment.find(present_attachment_id)
    p_att_origin = present_attachment.file.path
    p_att = File.exist?(p_att_origin) ? p_att_origin : present_attachment.file.mp4.path
    def_mp4_params = "-acodec libfaac -ab 128k -ac 2 -vcodec libx264 -crf 22"

    if present_attachment.attachment_type == "presentation_video" and params["playback_points"]
      timing = params["playback_points"]#.each{|e| e.each{|k| k[1].gsub!(",",".")}}
      files = []
      tmp_dir = File.join(File.dirname(p_att), SecureRandom.hex(10))
      frame_rate = FFMPEG::Movie.new(p_att).frame_rate || 25
      FileUtils.mkdir_p(tmp_dir)

      timing.each_with_index do |t, idx|
        if idx <= timing.size and [t['start'], t['stop'], t['duration'], t['pause_duration']].all?
          hex = idx.to_s+"_"+SecureRandom.hex(10)
          file_prefix = File.join(tmp_dir, hex)
          pic_path = File.join(tmp_dir, hex)+".jpg"

          # part before paused
          %x[ffmpeg -i #{p_att}  -ss #{t['start'].gsub(',', '.')} -t #{t['duration'].gsub(',', '.')} -r #{frame_rate} #{def_mp4_params} #{file_prefix}_1.mp4]

          files << file_prefix+"_1.mp4"

          if t['pause_duration'] != "0"
            # pic
            %x[ffmpeg -i #{p_att} -ss #{t['stop'].gsub(',', '.')} -sameq -vframes 1 #{pic_path}]

            # paused part
            %x[ffmpeg -loop 1 -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -ar 44100 -i /dev/zero -vcodec libx264 -preset medium -tune animation -vprofile baseline -r #{frame_rate} -t #{t['pause_duration'].gsub(',', '.')} -map 0:0 -map 1:0 #{file_prefix}_2.mp4]
            files << file_prefix+"_2.mp4"
          end
        end
      end

      hex = SecureRandom.hex(10)
      file_no_sound = File.join(tmp_dir, hex)+"_nosound_final.mp4"
      final = File.join(File.dirname(p_att), hex)+"_final.mp4"
      # %x[mkvmerge -o #{final} #{files.join(" +")}]
      # %x[MP4Box -cat #{files.join(" -cat ")} -new #{file_no_sound}]
      mnc_opts = "-ovc x264 -x264encopts subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:weight_b:crf=20 -oac faac -nosound"
      %x[mencoder #{mnc_opts} #{files.join(" ")} -o #{file_no_sound}]

      # add empty audio track
      %x[ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -g 50 #{def_mp4_params} #{final} -map 1:0 -map 0:0]

      FileUtils.remove_dir(tmp_dir)
      Resque.enqueue(VideoMerge, final, recorded_attachment_id, {:position => params["position"]})
    end
  end
end