# frozen_string_literal: true

class AnalyticsJob < ApplicationJob
  queue_as :default

  def perform(browser_name, browser_version, platform, ip, path, vidmaniero)
    g = Geocoder.search(ip).first
    Analytic.create!(browser: browser_name, version: browser_version, platform: platform, ip: ip,
                     country: g.try(:country), region: g.try(:region), city: g.try(:city),
                     path: path, vidmaniero: vidmaniero)
  end
end
