#!/bin/sh

PGPASSWORD=postgres psql -d eventaservo_devel -h localhost -U postgres -c 'drop schema public CASCADE;'
PGPASSWORD=postgres psql -d eventaservo_devel -h localhost -U postgres -c 'create schema public;'
PGPASSWORD=postgres pg_restore \
  --host localhost \
  --username postgres \
  --dbname "eventaservo_devel" \
  --role "postgres" \
  --verbose \
  $1
