# == Schema Information
#
# Table name: videos
#
#  id          :bigint           not null, primary key
#  description :string
#  title       :string
#  url         :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  event_id    :integer          not null
#
FactoryBot.define do
  factory :video do
    description { Faker::Lorem.sentence }
    title { Faker::Lorem.sentence }
    url { "https://www.youtube.com/watch?v=123456" }

    association :evento, factory: :event
  end
end
