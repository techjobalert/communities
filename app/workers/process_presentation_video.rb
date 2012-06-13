class ProcessPresentationVideo
  @queue = :store_asset

  def self.perform(present_attachment_id, recorded_attachment_id, params)
    present_attachment = Attachment.find(present_attachment_id)
    p_att_origin = present_attachment.file.path
    p_att = File.exist?(p_att_origin) ? p_att_origin : present_attachment.file.mp4.path
    def_mp4_params = "-acodec libfaac -ab 128k -ac 2 -vcodec libx264 -crf 22"

    if present_attachment.attachment_type == "presentation_video" and params["playback_points"]
      timing = params["playback_points"].each{|e| e.each{|k| k[1].gsub!(",",".")}}
      files = []
      tmp_dir = File.join(File.dirname(p_att), SecureRandom.hex(10))
      frame_rate = FFMPEG::Movie.new(p_att).frame_rate
      FileUtils.mkdir_p(tmp_dir)

      timing.each_with_index do |t, idx|
        if idx+1 <= timing.size and [t['start'], t['stop'], t['duration'], t['pause_duration']].all?
          hex = idx.to_s+"_"+SecureRandom.hex(10)
          file_prefix = File.join(tmp_dir, hex)
          pic_path = File.join(tmp_dir, hex)+".jpg"
          # pic
          %x[ffmpeg -i #{p_att} -ss #{t['stop']} -sameq -vframes 1 #{pic_path}]

          # part before paused
          %x[ffmpeg -i #{p_att}  -ss #{t['start']} -t #{t['duration']} #{def_mp4_params} #{file_prefix}_1.mp4]

          # %x[mencoder -oac copy -ovc copy -ss #START_TIME# -endPos #DURATION#  input.avi -o clip.avi]
          # paused part
          %x[ffmpeg -loop_input -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -vcodec libx264 -crf 22 -r #{frame_rate} -t #{t['pause_duration']} -map 0:0 -map 1:0 #{file_prefix}_2.mp4]

          files << file_prefix+"_1.mp4"
          files << file_prefix+"_2.mp4"

        end
      end

      hex = SecureRandom.hex(10)
      file_no_sound = File.join(tmp_dir, hex)+"_nosound_final.mp4"
      final = File.join(File.dirname(p_att), hex)+"_final.mp4"
      # %x[mkvmerge -o #{final} #{files.join(" +")}]
      # %x[mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{file_no_sound}]
      %x[MP4Box -cat #{files.join(" -cat ")}- new #{file_no_sound}]
      # add empty audio track
      %x[ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -g 50 #{def_mp4_params} #{final} -map 1:0 -map 0:0]

      FileUtils.remove_dir(tmp_dir)
      Resque.enqueue(VideoMerge, final, recorded_attachment_id, {:position => params["position"]})
    end
  end
end
