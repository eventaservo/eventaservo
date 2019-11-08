# frozen_string_literal: true

FactoryBot.define do
  factory :organizo, class: :organization do
    name { Faker::Company.name }
    short_name { Faker::Company.name.downcase.tr(' ', '_')}
    city { Faker::Address.city }
    country_id { 31 }
    email { Faker::Internet.email }
  end

  factory :bejo, class: :organization do
    name { 'Brazila Esperanta Junulara Organizo' }
    short_name { 'BEJO' }
    city { Faker::Address.city }
    country_id { 31 }
    email { Faker::Internet.email }
  end

  factory :tejo, class: :organization do
    name { 'Tutmonda Esperanta Junulara Organizo' }
    short_name { 'TEJO' }
    city { Faker::Address.city }
    country_id { 31 }
    email { Faker::Internet.email }
  end
end
