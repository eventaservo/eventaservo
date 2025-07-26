# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :string
#  admin                  :boolean          default(FALSE)
#  authentication_token   :string(30)       uniquely indexed
#  avatar                 :string
#  birthday               :date
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string           uniquely indexed
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  disabled               :boolean          default(FALSE), indexed
#  email                  :string           default(""), not null, uniquely indexed
#  encrypted_password     :string           default(""), not null
#  events_count           :integer          default(0), indexed
#  failed_attempts        :integer          default(0), not null
#  image                  :string
#  instruo                :jsonb            not null
#  jwt_token              :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  ligiloj                :jsonb            not null
#  locked_at              :datetime
#  mailings               :jsonb
#  name                   :string
#  prelego                :jsonb            not null
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string           uniquely indexed
#  sign_in_count          :integer          default(0), not null
#  system_account         :boolean          default(FALSE)
#  ueacode                :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string           uniquely indexed
#  username               :string
#  webcal_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer
#
FactoryBot.define do
  factory :user, aliases: [:uzanto], class: :user do
    name { Faker::Name.unique.name }
    email { Faker::Internet.unique.email }
    city { Faker::Address.city }
    admin { false }
    password { Faker::Internet.password }
    confirmed_at { Time.now }
    last_sign_in_at { Time.now }
    last_sign_in_ip { Faker::Internet.ip_v4_address }
    created_at { Time.now - rand(1..12).months }
    country { Country.all.sample }
    instruo { {instruisto: true, nivelo: ["baza"], sperto: Faker::Lorem.paragraph} }
    prelego { {preleganto: true, temoj: Faker::Lorem.paragraph} }

    trait :brazila do
      country { Country.find_by(code: "br") }
    end

    trait :admin do
      admin { true }
    end

    trait :e2e_test_user do
      email { "admin@eventaservo.org" }
      password { "administranto" }
    end
  end
end
