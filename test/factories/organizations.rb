# frozen_string_literal: true

FactoryBot.define do
  factory :organization, class: :organization do
    name { Faker::Company.name }
    short_name { Faker::Internet.domain_word }
    city { Faker::Address.city }
    country { Country.all.sample }
    email { Faker::Internet.email }
    users { [create(:user)] }
    description { Faker::Lorem.paragraph_by_chars }

    after(:build) do |o|
      image = URI.open("https://loremflickr.com/400/200/insect")
      o.logo.attach(io: image, filename: "animal.jpg")
    end
  end

  trait :uea do
    name { "Universala Esperanto Asocio" }
    description { "Universala Esperanto-Asocio estis fondita en 1908 kiel organizaĵo de individuaj esperantistoj. Nuntempe UEA estas la plej granda internacia organizaĵo por la parolantoj de Esperanto kaj havas membrojn en 120 landoj." }
    short_name { "UEA" }
    city { "Rotterdam" }
    country { Country.find_by(code: "nl") }
    email { "uea@uea.org" }
    youtube { "https://www.youtube.com/user/UEAviva" }
    major { true }
    logo { Rack::Test::UploadedFile.new(Rails.root.join("app", "assets", "images", "uea_emblemeto.png"), "image/png") }
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
    description { "Tutmonda Esperantista Junulara Organizo (TEJO) estas organizo de junaj parolantoj de Esperanto kun individuaj membroj kaj landaj sekcioj en ĉirkaŭ 40 landoj. TEJO mem estas la junulara sekcio de Universala Esperanto-Asocio. Ĉefa sidejo troviĝas en Roterdamo, Nederlando." }
    short_name { "TEJO" }
    url { "www.tejo.org" }
    city { Faker::Address.city }
    country { Country.all.sample }
    email { "info@tejo.org" }
    major { true }
    logo { Rack::Test::UploadedFile.new(Rails.root.join("app", "assets", "images", "tejo.png"), "image/png") }
  end
end
