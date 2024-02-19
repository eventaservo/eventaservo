namespace :cron do
  desc "Generate stastistics"
  task generate_statistics: :environment do
    GenerateStatisticsJob.perform_later
    puts "GenerateStatisticsJob has been enqueued."
  end
end
