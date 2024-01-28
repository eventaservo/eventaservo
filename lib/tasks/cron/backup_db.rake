namespace :cron do
  desc "Backups the DB"
  task backup_db: :environment do
    BackupDbJob.perform_later
    puts "BackdbJob has been enqueued."
  end
end
