# frozen_string_literal: true

class AnalyticsJob < ApplicationJob
  queue_as :default

  def perform(browser_name, browser_version, platform, ip, path, vidmaniero)
    Analytic.create!(browser: browser_name, version: browser_version, platform: platform, ip: ip,
                     country: Geocoder.search(ip).first.try(:country), path: path, vidmaniero: vidmaniero)
  end
end
