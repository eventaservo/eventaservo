# == Schema Information
#
# Table name: event_recurrences
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE), not null, indexed => [frequency], indexed => [master_event_id]
#  day_of_month    :integer
#  days_of_week    :text
#  end_date        :date
#  end_type        :string           not null
#  frequency       :string           not null, indexed => [active]
#  interval        :integer          default(1), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  master_event_id :bigint           not null, indexed, indexed => [active]
#
# Foreign Keys
#
#  fk_rails_...  (master_event_id => events.id)
#
FactoryBot.define do
  factory :event_recurrence do
    association :master_event, factory: :event, is_recurring_master: true
    frequency { "weekly" }
    interval { 1 }
    end_type { "never" }
    active { true }

    trait :daily do
      frequency { "daily" }
      interval { 1 }
    end

    trait :weekly do
      frequency { "weekly" }
      interval { 1 }
      days_of_week { [1] } # Monday
    end

    trait :monthly do
      frequency { "monthly" }
      interval { 1 }
      day_of_month { 1 }
    end

    trait :with_end_date do
      end_type { "on_date" }
      end_date { 6.months.from_now.to_date }
    end

    trait :weekly_with_specific_days do
      frequency { "weekly" }
      days_of_week { [1, 3, 5] } # Monday, Wednesday, Friday
    end

    trait :monthly_with_specific_day do
      frequency { "monthly" }
      day_of_month { 15 }
    end

    trait :inactive do
      active { false }
    end

    trait :every_two_weeks do
      frequency { "weekly" }
      interval { 2 }
    end

    trait :every_three_months do
      frequency { "monthly" }
      interval { 3 }
    end

    # Factory for weekly recurrence ending on specific date
    factory :weekly_recurrence_with_end_date, traits: [:weekly, :with_end_date]

    # Factory for monthly recurrence on specific day
    factory :monthly_recurrence_on_15th, traits: [:monthly, :monthly_with_specific_day]

    # Factory for bi-weekly recurrence
    factory :biweekly_recurrence, traits: [:every_two_weeks, :with_end_date]

    # Factory for quarterly recurrence
    factory :quarterly_recurrence, traits: [:every_three_months, :with_end_date]

    # Factory for inactive recurrence
    factory :inactive_recurrence, traits: [:weekly, :inactive]
  end
end
