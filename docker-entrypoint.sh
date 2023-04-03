#!/bin/bash

set -e

start () {
  bundle exec rails s -b 0.0.0.0
}

spec () {
  bundle exec rspec
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
  spec)
    spec
    ;;
  migrate)
    migrate
    ;;
  *)
    others "$@"
    ;;
esac