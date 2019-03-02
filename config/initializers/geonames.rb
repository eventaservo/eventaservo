# Uzata per la gem 'timezone' por elekti la ĝustan horzonon laŭ koordinatoj

# Timezone::Lookup.config(:geonames) do |c|
#   c.username = 'eventaservo'
#   c.offset_etc_zones = true
# end

Timezone::Lookup.config(:google) do |c|
  c.api_key = Rails.application.credentials.google_maps_key
end
