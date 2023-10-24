# frozen_string_literal: true

class SitemapRefreshJob < ApplicationJob
  def perform
    return if Rails.env.development?

    SitemapRefresh.new.call
  end
end
