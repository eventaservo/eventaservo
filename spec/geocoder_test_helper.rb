Geocoder.configure(lookup: :test, ip_lookup: :test)
Geocoder::Lookup::Test.set_default_stub(
  [
    {
      coordinates: [40.71, -74.00],
      address: "New York, NY, USA",
      state: "New York",
      state_code: "NY",
      country: "United States",
      country_code: "US"
    }
  ]
)
