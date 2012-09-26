require 'net/http'

class PowerPointConvert
  @queue = :power_point_convert_queue
  
  #def self.perform(file_ext, uuid_filename, model_id)
  def self.perform(file_ext, uuid_filename, filename, model_id)
    #  Rails.logger.debug "#_______________________________________________begin"
    # s3 = AWS::S3.new
    # bucket = s3.buckets.to_a.last
    #  Rails.logger.debug "#_______________________________________________#{bucket}"
    # #bucket = buckets.first
    #  Rails.logger.debug "#_______________________________________________#{bucket}"
    # new_object = bucket.objects[uuid_filename]
    #  Rails.logger.debug "#_________________________________#{new_object}"
    # begin
    #   new_object.write(:file => filename)
    # rescue Exception => e 
    #    Rails.logger.debug "#_________________________________#{e.message}"
    # end
    #  Rails.logger.debug "#_________________________________end"
    output = %x[s3cmd put #{filename} s3://maia360/#{uuid_filename}]
    # Rails.logger.debug ""
    # if %w(.ppt .pptx).member? file_ext
    #   uri = URI(REMOTE_WIN_PATH)
    # elsif file_ext == ".key"
    #   uri = URI(REMOTE_MAC_PATH)
    # end
    uri = URI("http://23.22.196.79:50000/convert")
     begin
       res = Net::HTTP.post_form(uri, 'file' => uuid_filename, 'id' => model_id)
      # res = Net::HTTP.post_form(uri, 'file' => new_object.key, 'id' => model_id)
      #res = Net::HTTP.get_response(uri)
       #if res.is_a?(Net::HTTPSuccess)
         
       #end
     rescue Timeout::Error => e
       nil
     end
     Rails.logger.debug "#__________________            #{res.body}         _______________"
  end

end
