# frozen_string_literal: true

FactoryBot.define do
  factory :organization, class: :organization do
    name { Faker::Company.name }
    short_name { Faker::Internet.domain_word }
    city { Faker::Address.city }
    country { Country.all.sample }
    email { Faker::Internet.email }
    users { [create(:user)] }
  end

  trait :uea do
    name { "Universala Esperanto Asocio" }
    short_name { "UEA" }
    city { "Rotterdam" }
    country { Country.find_by(code: "nl") }
    email { "uea@uea.org" }
  end

  trait :bejo do
    name { "Brazila Esperanta Junulara Organizo" }
    short_name { "BEJO" }
    city { "São Paulo" }
    country { Country.all.sample }
    email { "bejo@bejo.org.br" }
  end

  trait :tejo do
    name { "Tutmonda Esperanta Junulara Organizo" }
    short_name { "TEJO" }
    city { Faker::Address.city }
    country { Country.all.sample }
    email { Faker::Internet.email }
  end
end
