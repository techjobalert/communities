class VideoMerge
  @queue = :video_merge

  def self.perform(name, name2)
    upload_dir = File.dirname(__FILE__) + '/../../vendor/erlyvideo/'

    output = %x[cd #{upload_dir} && ffmpeg -i #{name}_wide.mp4 -vf "movie=#{name2} [mv]; [in][mv] overlay=320:0" -vcodec libx264 -preset medium out.mp4]

    puts output
    puts "Processed a job!"
  end
end