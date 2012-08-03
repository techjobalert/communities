require 'resque'
require 'net/http'
require 'resque'

module Video

  module Convert
    @queue = :convert

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

			file_basename = File.basename(file, ".*")
      file_ext = File.extname(file)
      command = "osascript #{script} #{presentations_source} #{presentations_video} #{file_basename} #{file_ext}"
      output = %x[#{command}]
      File.open(log_file, 'w') {|f| f.puts(Time.now.to_s);f.puts(command) }
      if file_basename and id
	      _uri = "http://192.168.0.161/file/converted_pvideo?filename=#{file_basename}.mov&id=#{id}"
	      uri = URI(_uri)
	      req = Net::HTTP::Get.new(uri.request_uri)
	      req.basic_auth user, password

	      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
	        http.request(req)
	      }
	    end
    end
  end
end
