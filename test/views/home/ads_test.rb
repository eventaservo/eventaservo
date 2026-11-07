# frozen_string_literal: true

require "test_helper"

# Guards the ad partial against host-dependent image URLs.
#
# The home page caches the rendered ad block, so the partial must generate a
# path that works outside a request context (no http://host prefix).
class HomeAdsTest < ActionView::TestCase
  test "renders ad images with a relative proxy path" do
    ad = ads(:jes)
    ad.image.attach(io: file_fixture("jes.png").open, filename: "jes.png")

    html = ApplicationController.render(partial: "home/ads", locals: {ads: [ad]})

    assert_match %r{src="/rails/active_storage/representations/proxy/}, html
    refute_match %r{src="https?://}, html
    assert_match "reklam-bildo", html
  end
end
