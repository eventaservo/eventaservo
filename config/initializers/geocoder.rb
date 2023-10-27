Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # lookup: :nominatim,         # name of geocoding service (symbol)
  google: {
    api_key: Rails.application.credentials.google_maps_key || ENV["GOOGLE_MAPS_KEY"]
  },
  ipinfo_io: {
    api_key: Rails.application.credentials.ipinfo_key || ENV["IPINFO_KEY"]
  },
  lookup: :google,
  ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: :eo,                # ISO-639 language code
  use_https: true,              # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  cache: Redis.new(url: ENV["REDIS_URL"]),             # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :km,                 # :km for kilometers or :mi for miles
  distances: :linear          # :spherical or :linear
)
