#!/bin/bash
set -e

# remove stale server process handle
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# prepend "bundle exec" to passed command
exec bundle exec "$@"
