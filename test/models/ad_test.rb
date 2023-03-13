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
#  event_id   :bigint
#
# Indexes
#
#  index_ads_on_event_id  (event_id)
#
require "test_helper"

class AdTest < ActiveSupport::TestCase
  test "should fail if no url" do
    ad = FactoryBot.build(:ad)

    assert ad.valid?

    ad.url = nil
    assert_not ad.valid?
  end
end
