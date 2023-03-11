Geocoder.configure(
  google: {
    api_key: ENV["GOOGLE_MAPS_KEY"] || Rails.application.credentials.google_maps_key
  },
  ipinfo_io: {
    api_key: ENV["IPINFO_KEY"] || Rails.application.credentials.ipinfo_key
  },
  lookup: :google,
  ip_lookup: :ipinfo_io,
  language: :eo,
  use_https: true,
  cache: Redis.new(host: ENV["REDIS_SERVER"]),
  units: :km,
  distances: :linear
)
