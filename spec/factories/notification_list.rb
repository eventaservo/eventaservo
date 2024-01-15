# frozen_string_literal: true

FactoryBot.define do
  factory :notification_user, class: :notification_list do
    country { Country.all.sample }
    email { Faker::Internet.unique.email }
    code { Faker::Alphanumeric.alphanumeric(number: 10) }
  end
end
