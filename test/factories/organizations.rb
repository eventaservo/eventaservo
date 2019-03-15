# frozen_string_literal: true

FactoryBot.define do
  factory :organizo, class: :organization do
    name { Faker::Company.name }
    short_name { Faker::Company.name.downcase.tr(' ', '_')}
  end
end
