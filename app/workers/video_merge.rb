class VideoMerge
  @queue = :video_merge

  def self.perform(presentV, recordedV, params)
    #erlyvideo_path = File.expand_path(File.dirname(__FILE__) + '/../../vendor/erlyvideo/video/')
    video_path = '/home/buildbot/video'
    upload_dir = video_path+'/merged/'
    presentation_dir = video_path +'/video_storage/p_video/'
    records_dir = video_path +'/webcam_records/'
    misc_dir = video_path + '/misc/'

    base_name = File.basename(presentV, ".mp4")
    #output_filename = [base_name,SecureRandom.hex(10)].join("_").insert(-1, ".mp4")
    add_logo = false
    logo = "movie=%{logo} [logo]; [in][logo] overlay=%{pos} [out]" % {
      :pos => self.add_position('tl'),
      :logo => misc_dir+'logo.png'
    }

    options = {
      :output_filename => recordedV,
      :presentV => presentation_dir+presentV,
      :recordedV => records_dir+recordedV,
      :pos => self.add_position(),
      :pad => self.add_pad(),
    }

    if p = params[:position]
      if p == 'ml' or p == 'mr'
        options.merger!({:pad => self.add_pad(p)})
      end
      options.merger!({:pos => self.add_position(p)})
    end

    # command = 'ffmpeg -i %{presentV} -vf "movie=%{recordedV} [mv]; [in][mv] overlay=%{pos} [out]" -vcodec libx264 -preset medium %{output_filename}' % options
    command = 'ffmpeg -i %{presentV} -vf "movie=%{recordedV}, scale=180:-1, setpts=PTS-STARTPTS [movie];[in] setpts=PTS-STARTPTS, [movie] overlay=%{pos} [out]" -vcodec libx264 -preset medium %{output_filename}' % options
    command2 = 'ffmpeg -i %{presentV} -vf "[in]setpts=PTS-STARTPTS, pad=%{pad},[T1]overlay=%{pos}[out];movie=%{recordedV},setpts=PTS-STARTPTS[T1]" -vcodec libx264 -preset medium %{output_filename}' % options
    output = %x[cd #{upload_dir} && #{command}]
  end

  def self.add_pad(pad="mr", w=480, h=480, color="black")
    case pad
    when 'mr'
      'in_w+#{w}:in_h:0:0:#{color}'
    when ml
      'in_w+#{w}:in_h:#{w}:0:#{color}'
    else
      'in_w+#{w}:in_h:0:0:#{color}'
    end
  end

  def self.add_position(pos="")
    case pos
    when 'tr'
      'main_w:0'
    when 'tl'
      '0:0'
    when 'br'
      'main_w-overlay_w:main_h-overlay_h'
    when 'bl'
      '0:main_h-overlay_h'
    when 'mr'
      'main_w-overlay_w:(main_h-overlay_h)/2'
    when 'ml'
      '0:(main_h-overlay_h)/2'
    when 'tm'
      '(main_w/2)-(overlay_w/2):5'
    when 'bm'
      '(main_w/2)-(overlay_w/2):main_h-overlay_h-5'
    else
      'main_w-overlay_w:main_h-overlay_h'
    end
  end
end