# == Schema Information
#
# Table name: event_reports
#
#  id         :bigint           not null, primary key
#  title      :string           not null
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
    title { Faker::Lorem.sentence(word_count: 6, random_words_to_add: 2) }
    content do
      "<p>#{Faker::Lorem.paragraph_by_chars(number: rand(200..300))}</p><br />" \
        "<p><strong>#{Faker::Lorem.paragraph_by_chars(number: rand(100..150))}</strong></p><br />" \
        "<p>#{Faker::Lorem.paragraph_by_chars(number: rand(200..300))}</p>"
    end
    user
  end
end
