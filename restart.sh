#!/bin/sh
RAILS_ENV=production rake assets:clean &&  rake assets:precompile && god restart resque && sudo restart orthodontics360 > log/restart.log 2>&1 & 

