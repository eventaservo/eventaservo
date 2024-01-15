# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_event_reports_on_event_id  (event_id)
#  index_event_reports_on_user_id   (user_id)
#
FactoryBot.define do
  factory :event_report, class: Event::Report do
    event
    user

    title { Faker::Lorem.sentence(word_count: 6, random_words_to_add: 2) }
    url { Faker::Internet.url }
  end
end
