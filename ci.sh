bundle exec rails db:migrate
bundle exec rails db:seed:replant
bundle exec rails server -b "ssl://0.0.0.0:3000?key=certs/localhost.key&cert=certs/localhost.crt" &
sleep 5
npx cypress run
