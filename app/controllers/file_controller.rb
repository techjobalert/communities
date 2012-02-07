require 'net/http'

class FileController < ApplicationController

  def upload_psource
    params[:files].each do |file|
      File.open('../video/video_storage/p_source/' + file.original_filename, "wb") do |f|
        f.write(file.read)
      end
      #uri = URI('http://192.168.0.251:3000/convert')
      #res = Net::HTTP.post_form(uri, 'file' => file.original_filename)
    end
    #redirect_to "/file/load"
    render :json => {:file => {:name => "123"}}
  end

  def converted_pvideo
    converted_pvideo
  end
  
  def webrecorder
    @uuid = SecureRandom.hex(10)
  end

  def convert
    Resque.enqueue(VideoConvert, params[:name])
  end

  def merge
    Resque.enqueue( VideoMerge,
                    params[:presentationVideoFileName],
                    params[:recordingFileName],
                    {}
                  )
    render :json => {success: true, msg: "merge request added to Q"}
  end

  # def thumbnail
  #   ffmpeg  -itsoffset -4  -i test.avi -vcodec mjpeg -vframes 1 -an -f rawvideo -s 320x240 test.jpg
  # end

end
