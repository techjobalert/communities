require 'net/http'

class PowerPointConvert
  @queue = :power_point_convert_queue

  def self.perform file_ext, uuid_filename, model_id
    if %w(.ppt .pptx).member? file_ext
      uri = URI(REMOTE_WIN_PATH)
    elsif file_ext == ".key"
      uri = URI(REMOTE_MAC_PATH)
    end

    begin
      Net::HTTP.post_form(uri, 'file' => uuid_filename, 'id' => model_id)
    rescue Timeout::Error => e
      nil
    end

  end

end
