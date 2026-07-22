# Configures the Geocoder gem to convert addresses into coordinates.
# For IP geocoding, uses the MaxMind GeoLite2 local database — no external API
# calls means no rate limits, no latency, and no API keys to manage.
#
# Download the GeoLite2-City.mmdb file:
#   bin/download-geolite2-db.sh
#
# Documentation: https://github.com/alexreisner/geocoder

Geocoder.configure(
  # IP address geocoding using the MaxMind offline database (.mmdb format)
  ip_lookup: :maxminddb,
  maxminddb: {
    file: Rails.root.join("GeoLite2-City.mmdb").to_s
  },

  # Address → coordinate lookup (for address fields, not IPs)
  lookup: Rails.env.development? ? :nominatim : :google,
  google: {
    api_key: Rails.application.credentials.dig(:google, :geocoding_api_key) || ENV["GOOGLE_GEOCODING_API_KEY"]
  },
  nominatim: {
    http_headers: {"User-Agent" => "EventaServo (https://eventaservo.org)"}
  },
  language: :eo,
  use_https: true,
  cache: Geocoder::CacheStore::Generic.new(Rails.cache, {}),
  units: :km,
  distances: :linear
)
