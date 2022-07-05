rails: truncate -s 0 log/*; bundle exec bin/rails server -u Puma -b 0.0.0.0 -p 3000 -e development -b 'ssl://0.0.0.0:3000?key=./certs/localhost.key&cert=./certs/localhost.crt'
worker: bundle exec bin/rake jobs:work
redis: redis-server 
webpack: bundle exec bin/webpack-dev-server
