# frozen_string_literal: true

# Solid Queue and Mission Control Jobs configuration

Rails.application.configure do
  # Disable HTTP Basic Auth for Mission Control Jobs
  # Authentication is handled through application routes with admin user restriction
  config.mission_control.jobs.http_basic_auth_enabled = false
end
