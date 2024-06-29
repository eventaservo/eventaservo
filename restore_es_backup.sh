#!/bin/sh

DB_HOST=${DB_HOST:-localhost}

PGPASSWORD=postgres psql -h "$DB_HOST" -d eventaservo_devel -U postgres -c 'drop schema public CASCADE;'
PGPASSWORD=postgres psql -h "$DB_HOST" -d eventaservo_devel -U postgres -c 'create schema public;'
PGPASSWORD=postgres pg_restore \
  --host "$DB_HOST" \
  --username postgres \
  --dbname "eventaservo_devel" \
  --role "postgres" \
  --verbose \
  $1
