#!/bin/bash

set -e

# belongs to the attempt of creating truffleruby image but it was too slow
#source /etc/profile.d/rvm.sh

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rails s -b 0.0.0.0