# frozen_string_literal: true

class AnalyticsJob < ApplicationJob
  queue_as :default

  def perform(browser_name, browser_version, platform, ip, path, vidmaniero)
    return false if duplicate?(browser_name, browser_version, platform, ip, path, vidmaniero)

    g = Geocoder.search(ip).first
    Analytic.create!(
      browser: browser_name,
      version: browser_version,
      platform: platform,
      ip: ip,
      country: g.try(:country),
      region: g.try(:region),
      city: g.try(:city),
      path: path,
      vidmaniero: vidmaniero
    )
  end

  private

    def duplicate?(browser_name, browser_version, platform, ip, path, vidmaniero)
      Analytic.where(
        created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day,
        browser: browser_name,
        version: browser_version,
        platform: platform,
        ip: ip,
        path: path,
        vidmaniero: vidmaniero
      ).any?
    end
end
