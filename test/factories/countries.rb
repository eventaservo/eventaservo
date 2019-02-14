# frozen_string_literal: true

FactoryBot.define do
  factory :lando, class: Country do
    name { Faker::Address.unique.country }
    continent { 'Ameriko' }
    code { Faker::Address.unique.country_code }

    trait :brazilo do
      name { 'Brazilo' }
      continent { 'Ameriko' }
      code { 'br' }
    end

    trait :argentino do
      name { 'Argentino' }
      continent { 'Ameriko' }
      code { 'ar' }
    end

    trait :hungario do
      name { 'Hungario' }
      continent { 'Eŭropo' }
      code { 'hu' }
    end

    trait :togolando do
      name { 'Togolando' }
      continent { 'Afriko' }
      code { 'tg' }
    end

    trait :usono do
      name { 'Usono' }
      continent { 'Ameriko' }
      code { 'us' }
    end

    trait :australio do
      name { 'Australio' }
      continent { 'Oceanio' }
      code { 'au' }
    end

    trait :cehio do
      name { 'Ĉeĥio' }
      continent { 'Eŭropo' }
      code { 'cz' }
    end

    trait :japanio do
      name { 'Japanio' }
      continent { 'Azio' }
      code { 'jp' }
    end

    trait :reta do
      name { 'Reta Evento' }
      continent { 'Reta' }
      code { 'ol' }
    end
  end
end
