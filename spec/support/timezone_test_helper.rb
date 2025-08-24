# Timezone configuration for RSpec tests
::Timezone::Lookup.config(:test)

# Stub common coordinate pairs to avoid external API calls
::Timezone::Lookup.lookup.stub(40.71, -74.00, "America/New_York")
::Timezone::Lookup.lookup.stub(-23.55, -46.63, "America/Sao_Paulo")
::Timezone::Lookup.lookup.stub(-7.11, -34.86, "America/Fortaleza")
::Timezone::Lookup.lookup.stub(43.66590881347656, -79.38521575927734, "America/Toronto")
::Timezone::Lookup.lookup.stub(48.8566, 2.3522, "Europe/Paris")
::Timezone::Lookup.lookup.stub(51.5074, -0.1278, "Europe/London")

# Set default timezone for any coordinates not explicitly stubbed
::Timezone::Lookup.lookup.default("Etc/UTC")
