# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/app/log/cronjobs.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 20.minutes do
  rake "cron:workerheartbeat"
end

every 6.hours do
  rake "cron:sitemap_refresh"
end

every 1.day, at: "5am" do
  rake "cron:backup_db"
end

every 1.day, at: "1am" do
  rake "cron:generate_statistics"
end
