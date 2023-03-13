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
FactoryBot.define do
  factory :ad do
    url { Rails.application.routes.url_helpers.international_calendar_url }

    after(:build) do |ad|
      image = URI.open("https://loremflickr.com/400/200/culture")
      ad.image.attach(io: image, filename: "ad.jpg")
    end
  end
end
