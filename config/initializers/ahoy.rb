class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
    # GDPR compliance
  end
end

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = true if Rails.env.production?

# GDPR compliance
Ahoy.mask_ips = true
Ahoy.cookies = false

# Disables Ahoy on Development and Test environments
Ahoy.exclude_method = lambda do |controller, request|
  Rails.env.development? || Rails.env.test?
end
