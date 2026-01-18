# frozen_string_literal: true

FactoryBot.define do
  factory :log, class: :log do
    user { create(:user) }
    loggable { create(:event) }
  end
end
