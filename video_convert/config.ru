#!/usr/bin/env ruby
require 'logger'
require 'resque/server'

require './application'

use Rack::ShowExceptions

AUTH_PASSWORD = ENV['AUTH']
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new \
  "/"       => Video::App.new,
  "/resque" => Resque::Server.new
