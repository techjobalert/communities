rails_env = ENV['RAILS_ENV'] || 'production'

# 16 workers and 1 master
worker_processes rails_env == 'production' ? 10 : 1


APP_ROOT = "/home/kir/dev/orthodontics360"
working_directory APP_ROOT

# This loads the application in the master process before forking
# worker processes
# Read more about it here:
# http://unicorn.bogomips.org/Unicorn/Configurator.html
preload_app true

timeout 30

# This is where we specify the socket.
# We will point the upstream Nginx module to this socket later on
listen "#{APP_ROOT}/tmp/sockets/unicorn.sock", :backlog => 64

pid "#{APP_ROOT}/tmp/pids/unicorn.pid"

# Set the path of the log files inside the log folder of the testapp
stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stdout.log"

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = "#{APP_ROOT}/Gemfile"
end

before_fork do |server, worker|
# This option works in together with preload_app true setting
# What is does is prevent the master process from holding
# the database connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
# Here we are establishing the connection after forking worker
# processes
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end