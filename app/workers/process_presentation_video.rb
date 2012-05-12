class ProcessPresentationVideo
  @queue = :store_asset

  def self.perform(present_attachment_id, recorded_attachment_id, params)
    present_attachment = Attachment.find(present_attachment_id)
    p_att = File.join(Rails.root.to_s,"public", present_attachment.file.webm.to_s)

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
          p "ffmpeg -i #{p_att} -ss #{t['stop']} -sameq -vframes 1 #{pic_path}"
          %x[ffmpeg -i #{p_att} -ss #{t['stop']} -sameq -vframes 1 #{pic_path}]

          # part before paused
          p "ffmpeg -i #{p_att} -vcodec copy -acodec copy -ss #{t['start']} -t #{t['duration']} #{file_prefix}_1.webm"
          %x[ffmpeg -i #{p_att} -vcodec copy -acodec copy -ss #{t['start']} -t #{t['duration']} #{file_prefix}_1.webm]

          # %x[mencoder -oac copy -ovc copy -ss #START_TIME# -endPos #DURATION#  input.avi -o clip.avi]
          # paused part
          p "ffmpeg -loop_input -shortest -y -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r #{frame_rate} -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm"
          %x[ffmpeg -loop_input -shortest -y -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r #{frame_rate} -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm]

          files << file_prefix+"_1.webm"
          files << file_prefix+"_2.webm"
        end
      end

      hex = SecureRandom.hex(10)
      file_no_sound = File.join(tmp_dir, hex)+"_nosound_final.webm"
      final = File.join(File.dirname(p_att), hex)+"_final.webm"
      # %x[mkvmerge -o #{final} #{files.join(" +")}]
      p "mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{file_no_sound}"
      %x[mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{file_no_sound}]
      # add empty audio track
      p "ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -vcodec libvpx -acodec libvorbis #{final} -map 1:0 -map 0:0"
      %x[ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -vcodec libvpx -acodec libvorbis #{final} -map 1:0 -map 0:0]
      #FileUtils.remove_dir(tmp_dir)
      Resque.enqueue(VideoMerge, final, recorded_attachment_id, {:position => params["position"]})
    end
  end
end
