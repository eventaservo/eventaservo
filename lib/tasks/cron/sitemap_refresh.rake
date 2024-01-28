namespace :cron do
  desc "Refreshes the sitemap"
  task sitemap_refresh: :environment do
    SitemapRefreshJob.perform_later
    puts "SitemapRefreshJob has been enqueued."
  end
end
