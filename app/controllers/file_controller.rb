class FileController < ApplicationController

  def upload
    file = params[:file]
    File.open('vendor/erlyvideo/videos/uploads/' + file.original_filename, "wb") do |f|
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
    # [0, 2.8611950874328613, 5.701964855194092, 8.517133712768555, 11.335606575012207, 13.571151733398438, 15.560884475708008, 17.36725616455078, 17.875, 17.875]
    Resque.enqueue( VideoMerge,
                    params[:presentationVideoFileName],
                    params[:recordingFileName],
                    params[:stopPoints]
                  )
    render :json => {success: true, msg: "merge request added to Q"}
  end

  # def thumbnail
  #   ffmpeg  -itsoffset -4  -i test.avi -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 test.jpg
  # end

end
