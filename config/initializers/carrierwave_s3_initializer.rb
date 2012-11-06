CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       
    :aws_access_key_id      => 'AKIAJNI4CYBPCXDB2YCA',       
    :aws_secret_access_key  => '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',
    :region => 'eu-west-1'
  }
  config.fog_directory  = Rails.env.development? ? 'maia360dev' : 'maia360'                     
  config.fog_public     = true                                  
end