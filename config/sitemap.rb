# Set the host name for URL creation

SitemapGenerator::Sitemap.default_host = "https://eventaservo.org" if Rails.env == 'production'
SitemapGenerator::Sitemap.default_host = "https://staging.eventaservo.org" if Rails.env == 'staging'
SitemapGenerator::Sitemap.default_host = "https://devel.eventaservo.org" if Rails.env == 'development'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  Event.find_each do |event|
      add event_path(event.code), lastmod: event.updated_at
  end
end
