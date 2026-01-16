# frozen_string_literal: true

# == Schema Information
#
# Table name: ads
#
#  id         :bigint           not null, primary key
#  active     :boolean          default(TRUE)
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           indexed
#

require "test_helper"

class AdTest < ActiveSupport::TestCase
  test "should have one attached image" do
    ad = Ad.new
    assert_respond_to ad, :image
  end

  test "should validate presence of url" do
    ad = Ad.new
    assert_not ad.valid?
    assert_includes ad.errors[:url], "devas esti kompletigita"
  end

  test "should validate presence of image" do
    ad = Ad.new(url: "https://example.com")
    assert_not ad.valid?
    assert_includes ad.errors[:image], "devas esti kompletigita"
  end
end
