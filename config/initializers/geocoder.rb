# Configures the Geocoder gem to convert addresses into coordinates.
# To use the Google provider, you need an API key with the "Geocoding API" enabled.
# In the Google Cloud Console, it is recommended to restrict this key to the "Geocoding API" only.
#
# Documentation: https://github.com/alexreisner/geocoder

Geocoder.configure(
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # lookup: :nominatim,         # name of geocoding service (symbol)
  google: {
    api_key: Rails.application.credentials.dig(:google, :geocoding_api_key) || ENV["GOOGLE_GEOCODING_API_KEY"]
  },
  ipinfo_io: {
    api_key: Rails.application.credentials.ipinfo_key || ENV["IPINFO_KEY"]
  },
  nominatim: {
    http_headers: {"User-Agent" => "EventaServo (https://eventaservo.org)"}
  },
  lookup: Rails.env.development? ? :nominatim : :google,
  ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: :eo,                # ISO-639 language code
  use_https: true,              # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  cache: Geocoder::CacheStore::Generic.new(Rails.cache, {}),             # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: :all,

  # Calculation options
  units: :km,                 # :km for kilometers or :mi for miles
  distances: :linear          # :spherical or :linear
)
