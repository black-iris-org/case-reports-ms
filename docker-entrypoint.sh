#!/bin/bash

set -e

start () {
  bundle exec rails s -b 0.0.0.0
}

migrate () {
  bundle exec rails migrate
}

others () {
  # Execute the custom command
  "$@"
}

# Determine which entrypoint to run based on the first argument
case "$1" in
  start)
    start
    ;;
  migrate)
    migrate
    ;;
  *)
    others "$@"
    ;;
esac