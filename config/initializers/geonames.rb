# Uzata per la gem 'timezone' por elekti la ĝustan horzonon laŭ koordinatoj

if Rails.env.test?
  Timezone::Lookup.config(:geonames) { |c|
    c.username         = 'eventaservo'
    c.offset_etc_zones = true
  }
else
  Timezone::Lookup.config(:google) { |c|
    c.api_key = Rails.application.credentials.google_maps_key
  }
end
