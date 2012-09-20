#!/bin/sh

cd /home/egor/projects/Orthodontics360/video_convert
RAILS_ENV=production bundle exec rake resque:work QUEUE=*
