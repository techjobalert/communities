class PresentationVideoUpload
	@queue = :store_asset

	def self.perform(attachment, filename, model_id, is_keynote)
		# remote_path = is_keynote ? REMOTE_MAC_PATH : REMOTE_WIN_PATH
		p_base = "#{Rails.root}/public/uploads/attachment/file/#{model_id}/"
		# %x[wget --user=user --password=orthodontics360 -P #{p_base} #{remote_path}/presentation_video/#{model_id}/#{filename}]
		# unless is_keynote
		# 	%x[wget --user=user --password=orthodontics360 -P #{p_base} #{remote_path}/presentation_video/#{model_id}/#{filename}.txt]
		# end
    # s3 = AWS::S3.new
    # bucket = s3.buckets.to_a.last
    
    # obj_video = bucket.objects[filename]

        %x[s3cmd get s3://maia360/#{filename} #{p_base+filename}]
        %x[s3cmd del s3://maia360/#{filename}]
        
    # File.open(p_base+filename,"wb") { |f| f.write obj_video.read }
    # bucket.objects.delete(filename)
    # unless  is_keynote
    #   filename_txt + filename+'.txt'
    #   obj_video = bucket.objects[filename_txt]
    #   File.open(p_base+filename_txt,"wb") { |f| f.write obj_video.read }
    #   bucket.objects.delete(filename_txt)
    # end


    


		p_video = File.join(p_base, filename)
		presenter_video = Attachment.new({
         :file => File.open(p_video),
         :user => attachment[:user_id],
         :item => attachment[:item_id],
         :attachment_type => "presentation_video"})
		 #collect timing from subtitles
      	# storing format "00:00:13,290;00:00:17,581" devider ";"
      	# timing = []
       #  if is_keynote
       #  	%x[MP4Box #{p_video} -srt 3 -std].each_line{|l| timing << l.split("-->")[1].strip() if l.include?("-->")}
       #  else
       #     p_source_timing = p_video+".txt"
       #     File.open(p_source_timing, 'r') do |file|
       #     	file.each_line{|l| timing << l.split("-->")[1].strip() if l.include?("-->")}
       #     end
       #     FileUtils.remove_file(p_source_timing, :verbose => true)
       #  end
       #  presenter_video.timing = timing.join(";")
       attach = Attachment.find(model_id)

        attach.item.attachments << presenter_video
      	# remove converted files(presentation and video file)
      	#FileUtils.rm [p_video, p_source], :verbose => true
	end


end