#!/bin/sh

source '/home/egor/.rvm/scripts/rvm';rvm 1.9.3; cd /home/egor/projects/Orthodontics360/video_convert && bundle exec thin start -d
