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

    file_ext = File.extname(uuid_filename)

    p file_ext
    logger.debug file_ext
    Rails.logger.debug file_ext

    if %w(.ppt .pptx).member? file_ext
      uri = URI(REMOTE_WIN_PATH)
    elsif file_ext == ".key"
      uri = URI(REMOTE_MAC_PATH)
    end

    Net::HTTP.post_form(uri, 'file' => uuid_filename) if uri||=nil
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

    attachment = Attachment.find(params[:id])
    if attachment
      is_keynote = File.extname(params[:filename]) == ".key"
      attachment.update_attribute("file_processing", nil)
      p_base = "/home/buildbot/video/video_storage"
      p_video = File.join(p_base, "p_video", params[:filename])
      p_source = File.join(p_base, "p_source", File.basename(params[:filename],".*")+ (is_keynote ? ".pptx" : ".key"))

      presenter_video = Attachment.new({
        :file => File.open(p_video),
        :user => attachment.user,
        :item => attachment.item,
        :attachment_type => "presentation_video"})

      #collect timing from subtitles
      # storing format "00:00:13,290;00:00:17,581" devider ";"
      timing = []
      if is_keynote
        %x[MP4Box #{p_video} -srt 3 -std].each_line{|l| timing << l.split("-->")[1].strip() if l.include?("-->")}
      else
        p_source_timing = p_video+".txt"
        File.open(p_source_timing, 'r') do |file|
          file.each_line{|l| timing << l.split("-->")[1].strip() if l.include?("-->")}
        end
        FileUtils.remove_file(p_source_timing, :verbose => true)
      end
      presenter_video.timing = timing.join(";")
      prev_attachment = attachment.item.attachments.where(attachment_type: "presentation_video")
      attachment.item.attachments << presenter_video

      # remove converted files(presentation and video file)
      FileUtils.rm [p_video, p_source], :verbose => true
      # remove prev attachment
      prev_attachment.destroy_all if prev_attachment
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
