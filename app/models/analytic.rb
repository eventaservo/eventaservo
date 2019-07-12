# frozen_string_literal: true

class Analytic < ApplicationRecord

  scope :lau_tago, ->(tago) { where(created_at: tago.beginning_of_day..tago.end_of_day) }

  def self.main_paths
    where("path = '/' OR lower(path) SIMILAR TO '(/ameriko%|/azio%|/e%c5%adropo%|/afriko%|/oceanio%|/reta%)'")
  end

  def self.vidmanieroj
    main_paths.where.not(vidmaniero: nil).select(:vidmaniero).distinct.order(:vidmaniero)
  end

  def self.delete_duplicates
    Analytic.order(:created_at).each do |a|
      r = Analytic.where(
        created_at: a.created_at.beginning_of_day..a.created_at.end_of_day,
        browser: a.browser, version: a.version, platform: a.platform, ip: a.ip, path: a.path,
        vidmaniero: a.vidmaniero
      ).where.not(id: a.id)

      r.destroy_all if r.any?
    end
  end
end
