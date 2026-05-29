class SitemapRefresh
  def call
    monitor_slug = "sitemap-refresh"
    check_in_id = Sentry.capture_check_in(monitor_slug, :in_progress)

    Eventaservo::Application.load_tasks
    Rake::Task["sitemap:refresh"].invoke

    Sentry.capture_check_in(monitor_slug, :ok, check_in_id:)
  rescue
    Sentry.capture_check_in(monitor_slug, :error, check_in_id:)
  end
end
