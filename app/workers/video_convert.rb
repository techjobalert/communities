# -*- coding: utf-8 -*-
class VideoConvert
  @queue = :video_convert

  def self.perform(name)
    upload_dir = File.dirname(__FILE__) + '/../../vendor/erlyvideo/'
    output = %x[cd #{upload_dir} && ffmpeg -i #{name} -vf "pad=640:240:0:0:black" -vcodec libx264 -preset medium #{name}_wide.mp4]
    puts output
  end
end