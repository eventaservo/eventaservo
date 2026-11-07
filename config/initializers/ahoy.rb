class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
    # GDPR compliance
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# Track bots
Ahoy.track_bots = Rails.env.test?

# IP geocoding is intentionally disabled: it enqueued one Ahoy::GeocodeV2Job
# per visit (~12.5k/day in production) and no code reads the country, city or
# latitude columns of ahoy_visits — GenerateStatisticsJob only rolls up events.
# If geographic data is needed later, geocode in batches, never per visit.
# See EVENTA-SERVO-283.
Ahoy.geocode = false

# GDPR compliance
Ahoy.mask_ips = true
Ahoy.cookies = true
Ahoy.visit_duration = 1.day
