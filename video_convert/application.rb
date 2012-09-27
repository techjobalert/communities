require 'rubygems'

require 'sinatra/base'
require 'sinatra/json'
require 'json'
require 'net/http'
require 'resque'

require './job'
require './redis'

module Video

  class App < Sinatra::Base
    helpers Sinatra::JSON

    set :server, 'thin'
    set :user, 'user'
    set :password, 'orthodontics360'
    set :pwd, File.dirname(__FILE__)
    set :json_content_type, :js
    set :script, settings.pwd + '/script.applescript'
    set :log_file, settings.pwd + '/log/video_convert.log'
    set :presentations_source, settings.pwd + '/video_storage/p_source/'
    set :presentations_video, settings.pwd + '/video_storage/p_video/'
    set :busy, false
    

    post '/convert' do
      file, id = params[:file], params[:id]
      if file and id
        Resque.enqueue(Convert, file, id)
      end
    end

  end
end
