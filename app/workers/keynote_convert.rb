require 'net/http'

class KeynoteConvert
  @queue = :keynote_convert_queue

  def self.perform uuid_filename, model_id
    uri = URI(REMOTE_MAC_PATH)
    begin
      Net::HTTP.post_form(uri, 'file' => uuid_filename, 'id' => model_id)
    rescue Timeout::Error => e
      nil
    end

  end

end
