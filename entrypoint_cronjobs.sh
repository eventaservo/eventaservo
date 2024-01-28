#!/bin/sh

set -e

# Whenever
bundle exec whenever --update-crontab --set environment=$RAILS_ENV
mkdir -p ./log && touch ./log/cronjobs.log

# Copia as variaveis de ambiente para que possam ser utilizadas pelo cron
printenv | grep -v "no_proxy" >> /etc/environment
cron

exec "$@"
