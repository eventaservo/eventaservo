#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rails db:migrate; \
  bundle exec rails server -b "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt"
