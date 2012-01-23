class FileController < ApplicationController

  def upload
    file = params[:file]
    File.open('vendor/erlyvideo/movies/uploads/' + file.original_filename, "wb") do |f|
      f.write(params[:file].read)
    end
    redirect_to "/file/load/#{file.original_filename}"
  end

  def load
    @file_name = params[:name]
  end

  def convert
    Resque.enqueue(VideoConvert, params[:name])
  end

  def merge
    Resque.enqueue(VideoMerge, params[:name], params[:name2])
  end

  # def thumbnail
  #   ffmpeg  -itsoffset -4  -i test.avi -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 test.jpg
  # end

end
