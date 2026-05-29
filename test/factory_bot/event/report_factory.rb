# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  event_id   :bigint           not null, indexed
#  user_id    :bigint           not null, indexed
#
FactoryBot.define do
  factory :event_report, class: Event::Report do
    event
    user

    title { Faker::Lorem.sentence(word_count: 6, random_words_to_add: 2) }
    url { Faker::Internet.url }
  end
end
