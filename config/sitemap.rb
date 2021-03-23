# Set the host name for URL creation

SitemapGenerator::Sitemap.default_host = "https://eventaservo.org" if Rails.env == 'production'
SitemapGenerator::Sitemap.default_host = "https://testservilo.eventaservo.org" if Rails.env == 'staging'
SitemapGenerator::Sitemap.default_host = "https://devel.eventaservo.org" if Rails.env == 'development'

SitemapGenerator::Sitemap.search_engines[:yahoo] = "http://www.bing.com/webmaster/ping.aspx?siteMap=%s"
SitemapGenerator::Sitemap.search_engines[:yandex] = "http://blogs.yandex.ru/pings/?status=success&url=%s"

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

  # Venontaj eventoj
  Event.venontaj.find_each do |event|
    add event_path(event.ligilo), lastmod: event.updated_at, priority: 1.0, changefreq: 'daily'
  end

  # Pasintaj Eventoj
  Event.pasintaj.find_each do |event|
    add event_path(event.ligilo), lastmod: event.updated_at, priority: 0.2, changefreq: 'weekly', expires: event.updated_at + 2.weeks
  end

  # Landoj
  Country.find_each do |country|
    add events_by_country_path(country.continent, country.name), priority: 0.7, changefreq: 'daily'
  end

  # Urboj
  Event.joins(:country).select(:city, 'countries.name as lando, countries.continent').distinct(:city).order('countries.name, city').each do |city|
    add events_by_city_path(city.continent, city.lando, city.city), priority: 0.7, changefreq: 'daily'
  end
end
