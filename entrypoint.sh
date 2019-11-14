#!/bin/sh
set -e

rm -rf tmp/pids/server.pid

exec "$@"