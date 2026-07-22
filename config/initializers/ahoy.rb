class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
    # GDPR compliance
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# Track bots
Ahoy.track_bots = true

# set to true for IP geocoding via the geocoder gem (configured below)
# Uses MaxMind GeoLite2 local database (no external API calls).
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = true if Rails.env.production?

# GDPR compliance
Ahoy.mask_ips = true
Ahoy.cookies = true
Ahoy.visit_duration = 1.day
