require 'net/http'

class FileController < ApplicationController
  before_filter :authenticate_user!, :except => [:converted_pvideo]

  def upload_psource
    uuid = params[:uuid]
    file = params[:file]
    uuid_filename = [uuid, file.original_filename].join("-")
    File.open('../video/video_storage/p_source/' + uuid_filename , "wb") do |f|
      f.write(file.read)
    end
    uri = URI('http://192.168.0.251:3000/convert')
    Net::HTTP.post_form(uri, 'file' => uuid_filename)
    #redirect_to "/file/load"
    render :json => {:file => {:name => uuid_filename} }
  end

  # def converted_pvideo
  #   if not params[:filename]
  #     render :nothing => true
  #     return false
  #   end
  #   pvideo_uuid = params[:filename].split("-").first()
  #   pvideo_file = params[:filename]
  #   wvideo = ""

  #   Dir.foreach("../video/webcam_records/") do |file|
  #     if file.include?(pvideo_uuid)
  #       wvideo = file
  #       break
  #     end
  #   end
  #   if pvideo_file and wvideo
  #     Resque.enqueue( VideoMerge, pvideo_file, wvideo, {})
  #   end
  #   render :nothing => true
  # end
  def converted_pvideo
    if not params[:filename] or not params[:id]
      render :nothing => true
      return false
    end

    video_path = "/home/buildbot/video/video_storage/p_video/#{params[:filename]}"

    attachment = Attachment.find(params[:id])
    if attachment
      attachment.update_attribute("file_processing", nil)
      cp = File.join(File.dirname(attachment.file.path), File.basename(attachment.file.path, '.*'))
      FileUtils::mv( video_path, File.join(cp, File.extname(params[:filename])) )
      attachment.file.recreate_versions!
    end
    render :nothing => true
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
