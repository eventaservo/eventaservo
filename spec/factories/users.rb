# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  about                  :string
#  admin                  :boolean          default(FALSE)
#  authentication_token   :string(30)
#  avatar                 :string
#  birthday               :date
#  city                   :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  disabled               :boolean          default(FALSE)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  events_count           :integer          default(0)
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
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_account         :boolean          default(FALSE)
#  ueacode                :string
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  username               :string
#  webcal_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :integer          default(99999)
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_disabled              (disabled)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_events_count          (events_count)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
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
    country { Country.all.sample }
    instruo { {instruisto: true, nivelo: ["baza"], sperto: Faker::Lorem.paragraph} }
    prelego { {preleganto: true, temoj: Faker::Lorem.paragraph} }

    after(:build) do |user|
      if Rails.env.development?
        picture = URI.parse(Faker::LoremFlickr.image(size: "256x256", search_terms: ["profile_picture"])).open
        user.picture.attach(io: picture, filename: user.name.parameterize + "-picture.jpg", content_type: "image/jpg")
      end
    end

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
