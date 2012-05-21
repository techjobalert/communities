class PowerPointConvert
  @queue = :power_point_convert_queue

  def self.perform uuid_filename, model_id
    Net::HTTP.post_form(uri, 'file' => uuid_filename, 'id' => model_id)
  end

end
