# == Schema Information
#
# Table name: tags
#
#  id                 :bigint           not null, primary key
#  display_in_filters :boolean          default(TRUE), not null
#  group_name         :string           not null, indexed => [name]
#  name               :string           not null, indexed => [group_name]
#  sort_order         :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
FactoryBot.define do
  factory :tag do
    name { Faker::Lorem.word.capitalize }
    group_name { "category" }
    sort_order { 0 }
    display_in_filters { true }

    trait :category do
      group_name { "category" }
      name { ["Kunveno/Evento", "Kurso", "Alia"].sample }
      sort_order { [100, 200, 300].sample }
    end

    trait :characteristic do
      group_name { "characteristic" }
      name { ["Anonco", "Konkurso", "Por junuloj"].sample }
      sort_order { [100, 200, 300].sample }
    end

    trait :time do
      group_name { "time" }
      name { ["Unutaga", "Plurtaga"].sample }
      sort_order { [100, 200].sample }
    end

    trait :hidden do
      display_in_filters { false }
    end
  end
end
