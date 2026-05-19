# Used by the 'timezone' gem to select the correct timezone based on coordinates.
# To use the Google service, you need an API key with the "Time Zone API" enabled.
# In the Google Cloud Console, it is recommended to restrict this key to the "Time Zone API" only.

if Rails.env.test?
  Timezone::Lookup.config(:geonames) { |c|
    c.username = "eventaservo"
    c.offset_etc_zones = true
  }
else
  Timezone::Lookup.config(:google) { |c|
    c.api_key = Rails.application.credentials.dig(:google, :timezone_api_key) || ENV["GOOGLE_TIMEZONE_API_KEY"]
  }
end
