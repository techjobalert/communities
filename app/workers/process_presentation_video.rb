class ProcessPresentationVideo
  @queue = :store_asset

  def self.perform(present_attachment_id, recorded_attachment_id, params)
    present_attachment = Attachment.find(present_attachment_id)
    # p_att = File.join(Rails.root.to_s,"public", present_attachment.file.webm.to_s)
    p_att = present_attachment.file.path

    if present_attachment.attachment_type == "presentation_video" and params["playback_points"]
      timing = params["playback_points"].each{|e| e.each{|k| k[1].gsub!(",",".")}}
      files = []
      tmp_dir = File.join(File.dirname(p_att), SecureRandom.hex(10))
      frame_rate = FFMPEG::Movie.new(p_att).frame_rate
      FileUtils.mkdir_p(tmp_dir)

      # debug log
      log_file_path = File.join(Rails.root, "log", "process_video.log")
      File.open(log_file_path, 'w') {|f| f.puts("");f.puts("[START][split-and-merge] " + Time.now.to_s) }

      timing.each_with_index do |t, idx|
        if idx+1 <= timing.size and [t['start'], t['stop'], t['duration'], t['pause_duration']].all?
          hex = idx.to_s+"_"+SecureRandom.hex(10)
          file_prefix = File.join(tmp_dir, hex)
          pic_path = File.join(tmp_dir, hex)+".jpg"
          # pic
          %x[ffmpeg -i #{p_att} -ss #{t['stop']} -sameq -vframes 1 #{pic_path}]

          # part before paused
          %x[ffmpeg -i #{p_att} -vcodec libvpx -acodec libvorbis -ss #{t['start']} -t #{t['duration']} #{file_prefix}_1.webm]

          # %x[mencoder -oac copy -ovc copy -ss #START_TIME# -endPos #DURATION#  input.avi -o clip.avi]
          # paused part
          %x[ffmpeg -loop_input -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r #{frame_rate} -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm]

          # debug log
          # File.open(log_file_path, 'w') do |f|
          #   f.puts "ffmpeg -i #{p_att} -ss #{t['stop']} -sameq -vframes 1 #{pic_path}"
          #   f.puts "ffmpeg -i #{p_att} -vcodec copy -acodec copy -ss #{t['start']} -t #{t['duration']} #{file_prefix}_1.webm"
          #   f.puts "ffmpeg -loop_input -f image2 -i #{pic_path} -acodec pcm_s16le -f s16le -i /dev/zero -r #{frame_rate} -t #{t['pause_duration']} -map 0:0 -map 1:0 -f webm -vcodec libvpx -ar 22050 -acodec libvorbis -aq 90 -ac 2 #{file_prefix}_2.webm"
          # end

          files << file_prefix+"_1.webm"
          files << file_prefix+"_2.webm"

        end
      end

      hex = SecureRandom.hex(10)
      file_no_sound = File.join(tmp_dir, hex)+"_nosound_final.webm"
      final = File.join(File.dirname(p_att), hex)+"_final.webm"
      # %x[mkvmerge -o #{final} #{files.join(" +")}]
      %x[mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{file_no_sound}]
      # add empty audio track
      %x[ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -g 50 -vcodec libvpx -acodec libvorbis #{final} -map 1:0 -map 0:0]

      # debug log
      File.open(log_file_path, 'w') do |f|
        f.puts "mencoder -nosound -oac copy -ovc copy #{files.join(" ")} -o #{file_no_sound}"
        f.puts "ffmpeg -shortest -ar 44100 -acodec pcm_s16le -f s16le -ac 2 -i /dev/zero -i #{file_no_sound} -g 50 -vcodec libvpx -acodec libvorbis #{final} -map 1:0 -map 0:0"
        f.puts("[END] " + Time.now.to_s)
      end

      #FileUtils.remove_dir(tmp_dir)
      Resque.enqueue(VideoMerge, final, recorded_attachment_id, {:position => params["position"]})
    end
  end
end
