# frozen_string_literal: true

FactoryBot.define do
  factory :lando_brazilo, class: Country do
    name { 'Brazilo' }
    continent { 'Ameriko' }
    code { 'br' }
  end

  factory :lando_argentino, class: Country do
    name { 'Argentino' }
    continent { 'Ameriko' }
    code { 'ar' }
  end

  factory :lando_hungario, class: Country do
    name { 'Hungario' }
    continent { 'Eŭropo' }
    code { 'hu' }
  end

  factory :lando_togolando, class: Country do
    name { 'Togolando' }
    continent { 'Afriko' }
    code { 'tg' }
  end

  factory :lando_usono, class: Country do
    name { 'Usono' }
    continent { 'Ameriko' }
    code { 'us' }
  end

  factory :lando_australio, class: Country do
    name { 'Australio' }
    continent { 'Oceanio' }
    code { 'au' }
  end

  factory :lando_cehio, class: Country do
    name { 'Ĉeĥio' }
    continent { 'Eŭropo' }
    code { 'cz' }
  end

  factory :lando_reta, class: Country do
    name { 'Reta Evento' }
    continent { 'Reta' }
    code { 'ol' }
  end
end
