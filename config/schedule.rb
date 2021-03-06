# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
every 1.day, :at => '01:30 am' do
  rake "ts:rebuild"
  runner "CarrierWave.clean_cached_files!"
end

every 1.day, :at => '02:00 am' do
  rake "paypal:transfer"
end

every 6.hours do
  rake "thinking_sphinx:index"
end

#every 10.minutes do
  # command "/usr/bin/some_great_command"
  # runner "MyModel.some_method"
  # rake "thinking_sphinx:index"
#end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
