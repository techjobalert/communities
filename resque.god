rails_env = ENV['RAILS_ENV'] || "production"
rails_root = ENV['RAILS_ROOT']

queues_array = ["notifications_queue,power_point_convert_queue",
                "store_asset,store_asset_notifications_queue",
                "convert",
                "*"]
queues_indexes = rails_env == 'production' ? [2,2,0,0,1,1,1,1,1,1] : [3,3]


queues_indexes.each_with_index do |elem,index|
  God.watch do |w|
    w.dir = "#{rails_root}"
    w.name = "resque-#{index}"
    w.group = 'resque'
    w.interval = 30.seconds
    w.env = {"QUEUE"=>queues_array[elem], "RAILS_ENV"=>rails_env}
   	w.start = "bundle exec rake resque:work"
    # restart if memory gets too high
    w.transition(:up, :restart) do |on|
      on.condition(:memory_usage) do |c|
        c.above = 350.megabytes
        c.times = 2
      end
    end

    # determine the state on startup
    w.transition(:init, { true => :up, false => :start }) do |on|
      on.condition(:process_running) do |c|
        c.running = true
      end
    end

    # determine when process has finished starting
    w.transition([:start, :restart], :up) do |on|
      on.condition(:process_running) do |c|
        c.running = true
        c.interval = 5.seconds
      end

      # failsafe
      on.condition(:tries) do |c|
        c.times = 5
        c.transition = :start
        c.interval = 5.seconds
      end
    end

    # start if process is not running
    w.transition(:up, :start) do |on|
      on.condition(:process_running) do |c|
        c.running = false
      end
    end
  end
end