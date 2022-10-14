# frozen_string_literal: true

FactoryBot.define do
  factory :ad do
    url { Rails.application.routes.url_helpers.international_calendar_url }

    after(:build) do |ad|
      image = URI.open("https://loremflickr.com/400/200/culture")
      ad.image.attach(io: image, filename: "ad.jpg")
    end
  end
end
