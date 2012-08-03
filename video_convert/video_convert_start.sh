#!/bin/sh

source '/Users/administrator/.rvm/scripts/rvm';rvm 1.9.3; cd ~/video_convert && bundle exec thin start -d
