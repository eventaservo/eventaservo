namespace :cron do
  desc "Sends heartbeat from background worker to Sentry"
  task workerheartbeat: :environment do
    WorkerHeartbeatJob.perform_later
    puts "WorkerHeartBeatJob has been enqueued."
  end
end
