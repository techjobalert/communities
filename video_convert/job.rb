require 'resque'
require 'net/http'

module Video

 # module Convert
  class Convert
    @queue = :converta

    def self.perform(file, id)
      server = 'thin'
      user = 'user'
      password = 'orthodontics360'
      pwd = File.dirname(__FILE__)
      json_content_type = :js
      script = pwd + '/script.applescript'
      log_file = pwd + '/log/video_convert.log'


      presentations_source = pwd + '/video_storage/p_source/'
      presentations_video = pwd + '/video_storage/p_video/'

      # sleep(10)

      # require File.join(pwd,'aws_setup')
      # s3 = AWS::S3.new
      # bucket = s3.buckets.to_a.last
      # obj_presentation = bucket.objects[file]
      # File.open(presentations_source+file,"wb") { |f| f.write obj_presentation.read }
      # bucket.objects.delete(file)
       %x[touch #{pwd}/test.txt]
       %x[s3cmd get s3://maia360/#{file} #{presentations_source+file}]
       %x[s3cmd del s3://maia360/#{file}]
		   file_basename = File.basename(file, ".*")
   #    file_ext = File.extname(file)
   #    command = "osascript #{script} #{presentations_source} #{presentations_video} #{file_basename} #{file_ext}"
   #    output = %x[#{command}]
   #    File.open(log_file, 'w') {|f| f.puts(Time.now.to_s);f.puts(command) }
      # obj_video = bucket.objects[file_basename+'.mov']
      # obj_video.write(:file => File.join(presentations_source,file_basename+file_ext))

       # %x[s3cmd put #{File.join(presentations_source,file_basename+file_ext)} s3://orthodontics360-test/#{file_basename+'.mov'}]
       %x[s3cmd put #{File.join(presentations_video,'video.mov')} s3://maia360/#{file_basename+'.mov'}]
     #  if file_basename and id
     #    _uri = "http://192.168.0.161/file/converted_pvideo?filename=#{file_basename}.mov&id=#{id}"
	    #   # _uri = "http://192.168.0.161/file/converted_pvideo?filename=#{obj_video.key}.mov&id=#{id}"
	    #   uri = URI(_uri)
	    #   req = Net::HTTP::Get.new(uri.request_uri)
	    #   req.basic_auth user, password

	    #   res = Net::HTTP.start(uri.hostname, uri.port) {|http|
	    #     http.request(req)
	    #   }
	    # end
      uri = URI("http://54.243.197.54/file/converted_pvideo?filename=#{file_basename}.mov&id=#{id}")
      req = Net::HTTP::Get.new(uri.request_uri)
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
           http.request(req)
      }
    end
  end
end
