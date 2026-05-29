# frozen_string_literal: true

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

Geocoder::Lookup::Test.add_stub(
  "Sao Paŭlo, BR", [
    {
      coordinates: [-23.55, -46.63],
      address: "Sao Paŭlo urbocentro",
      state: "Sao Paŭlo",
      state_code: "SP",
      country: "Brazil",
      country_code: "BR"
    }
  ]
)

Geocoder::Lookup::Test.add_stub(
  "Ĵoan-Pesoo, BR", [
    {
      coordinates: [-7.11, -34.86],
      address: "Centro",
      state: "Paraíba",
      state_code: "PB",
      country: "Brazil",
      country_code: "BR"
    }
  ]
)
