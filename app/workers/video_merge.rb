class VideoMerge
  @queue = :video_merge

  def self.perform(presentV, recordedV, posints)
    upload_dir = File.dirname(__FILE__) + '/../../vendor/erlyvideo/videos/merged-video/'

    output = %x[cd #{upload_dir} && ffmpeg -i #{name}_wide.mp4 -vf "movie=#{name2} [mv]; [in][mv] overlay=320:0" -vcodec libx264 -preset medium out.mp4]

    puts output
    puts "Processed a job!"
  end
end