# frozen_string_literal: true

FactoryBot.define do
  factory :organizo, class: :organization do
    name { Faker::Company.name }
    short_name { Faker::Company.name.downcase.tr(' ', '_')}
  end

  factory :bejo, class: :organization do
    name { 'Brazila Esperanta Junulara Organizo' }
    short_name { 'BEJO' }
  end

  factory :tejo, class: :organization do
    name { 'Tutmonda Esperanta Junulara Organizo' }
    short_name { 'TEJO' }
  end
end
