class ProcessPresentationVideo
  @queue = :store_asset

  def self.perform(present_attachment_id, params)
    present_attachment = Attachment.find(present_attachment_id)
    p_att = File.join(Rails.root.to_s,"public", present_attachment.file.webm.to_s)

    if present_attachment.attachment_type == "presentation_video" and params["playback_points"]
      timing = params["playback_points"].each{|e| e.each{|k| k[1].gsub!(",",".")}}
      files = []
      tmp_dir = File.join(File.dirname(p_att), SecureRandom.hex(10))
      FileUtils.mkdir_p(tmp_dir)
      timing.each_with_index do |t, idx|
        if idx+1 <= timing.size and [t['start'], t['stop'], t['pause_duration']].all?
          hex = SecureRandom.hex(10)
          file_prefix = File.join(tmp_dir, hex)
          pic_path = File.join(File.dirname(p_att), hex)+".jpg"
          # pic
          p "ffmpeg -ss #{t['stop']} -t 1 -i #{p_att} -f mjpeg #{pic_path}"
          %x[ffmpeg -ss #{t['stop']} -t 1 -i #{p_att} -f mjpeg #{pic_path}]
          # part before paused
          p "ffmpeg -ss #{t['start']} -t #{t['stop']} -i #{p_att} -vcodec copy -acodec copy #{file_prefix}_1.webm"
          %x[ffmpeg -ss #{t['start']} -t #{t['stop']} -i #{p_att} -vcodec copy -acodec copy #{file_prefix}_1.webm]
          # paused part
          p "ffmpeg -loop_input -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r 12 -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm"
          %x[ffmpeg -loop_input -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r 12 -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm]
          files << file_prefix+"_1.webm"
          files << file_prefix+"_2.webm"
        end
      end

      hex = SecureRandom.hex(10)
      file_prefix = File.join(File.dirname(p_att), hex)
      final = file_prefix+"_final.webm"
      # %x[mkvmerge -o #{final} #{files.join(" +")}]
      p "mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{final}"
      %x[mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{final}]
      FileUtils.remove_dir(tmp_dir)
      Resque.enqueue(VideoMerge, present_attachment_id, final, {:position => params["position"]})
    end
  end
end