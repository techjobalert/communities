#!/bin/sh

cd ~/video_convert
RAILS_ENV=production bundle exec rake resque:work QUEUE=*
