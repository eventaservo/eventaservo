# frozen_string_literal: true

# == Schema Information
#
# Table name: event_recurrences
#
#  id                 :bigint           not null, primary key
#  active             :boolean          default(TRUE), not null
#  day_of_month       :integer
#  day_of_week_monthly :integer
#  days_of_week       :integer          default([]), is an Array
#  end_date           :date
#  end_type           :string           default("never"), not null
#  frequency          :string           not null
#  interval           :integer          default(1), not null
#  last_generated_date :date
#  month_of_year      :integer
#  week_of_month      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  master_event_id    :bigint           not null, indexed
#
# Foreign Keys
#
#  fk_rails_...  (master_event_id => events.id)
#

# Defines how a master event repeats over time.
#
# Supports daily, weekly, monthly (fixed day or Nth weekday),
# and yearly recurrence patterns with configurable intervals
# and optional end dates.
#
# @example Weekly recurrence on Tuesdays and Thursdays
#   EventRecurrence.create!(
#     master_event: event,
#     frequency: "weekly",
#     interval: 1,
#     days_of_week: [2, 4],
#     end_type: "never"
#   )
#
# @example Monthly on the first Saturday
#   EventRecurrence.create!(
#     master_event: event,
#     frequency: "monthly",
#     interval: 1,
#     week_of_month: 1,
#     day_of_week_monthly: 6,
#     end_type: "on_date",
#     end_date: 1.year.from_now
#   )
class EventRecurrence < ApplicationRecord
  # -- Associations --

  belongs_to :master_event, class_name: "Event"
  has_many :generated_events,
    through: :master_event,
    source: :recurrent_child_events

  # -- Enums --

  enum :frequency, {
    daily: "daily",
    weekly: "weekly",
    monthly: "monthly",
    yearly: "yearly"
  }, prefix: true

  enum :end_type, {
    never: "never",
    on_date: "on_date"
  }, prefix: true

  # -- Validations --

  validates :frequency, presence: true
  validates :end_type, presence: true
  validates :interval, presence: true, numericality: {
    greater_than: 0,
    less_than_or_equal_to: 100
  }

  validates :end_date, presence: true, if: :end_type_on_date?
  validates :days_of_week, presence: true, if: :frequency_weekly?
  validates :month_of_year, presence: true, if: :frequency_yearly?

  validate :end_date_must_be_future, if: :end_type_on_date?
  validate :days_of_week_values_valid, if: :frequency_weekly?
  validate :monthly_pattern_valid, if: :frequency_monthly?
  validate :day_of_month_valid, if: -> { day_of_month.present? }
  validate :week_of_month_valid, if: -> { week_of_month.present? }
  validate :day_of_week_monthly_valid, if: -> { day_of_week_monthly.present? }
  validate :month_of_year_valid, if: -> { month_of_year.present? }
  validate :yearly_day_of_month_required, if: :frequency_yearly?
  validate :master_event_not_a_child

  # -- Scopes --

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Checks if this recurrence should still generate events
  #
  # @return [Boolean] true if active and not past end date
  def should_generate_events?
    return false unless active?

    case end_type
    when "never" then true
    when "on_date" then Date.current <= end_date
    else false
    end
  end

  # Returns the end date of the generation horizon.
  # Uses the later of today or the master event's start date as the base.
  #
  # @return [Date] how far into the future to generate events
  def horizon_end_date
    base = [Date.current, master_event.date_start.to_date].max
    cutoff = base + RecurringEventsConfig.horizon(frequency)

    if end_type_on_date? && end_date < cutoff
      end_date
    else
      cutoff
    end
  end

  # Returns the maximum number of child events to generate
  #
  # @return [Integer]
  def max_children
    RecurringEventsConfig.max_children(frequency)
  end

  # Deactivates the recurrence rule
  #
  # @return [Boolean] true if successfully deactivated
  def deactivate!
    update!(active: false)
  end

  # Reactivates the recurrence rule
  #
  # @return [Boolean] true if successfully reactivated
  def reactivate!
    update!(active: true)
  end

  private

  # @return [void]
  def end_date_must_be_future
    return unless end_date.present?

    errors.add(:end_date, "must be in the future") if end_date <= Date.current
  end

  # @return [void]
  def days_of_week_values_valid
    return if days_of_week.blank?

    valid_range = (0..6).to_a

    if (days_of_week - valid_range).any?
      errors.add(:days_of_week, "must contain values between 0 (Sunday) and 6 (Saturday)")
    end

    if days_of_week.uniq.length != days_of_week.length
      errors.add(:days_of_week, "must not contain duplicates")
    end
  end

  # @return [void]
  def monthly_pattern_valid
    has_fixed_day = day_of_month.present?
    has_nth_weekday = week_of_month.present? && day_of_week_monthly.present?

    if has_fixed_day && has_nth_weekday
      errors.add(:base, "monthly recurrence must use either day_of_month or week_of_month/day_of_week_monthly, not both")
    end

    unless has_fixed_day || has_nth_weekday
      errors.add(:base, "monthly recurrence requires day_of_month or week_of_month with day_of_week_monthly")
    end
  end

  # @return [void]
  def day_of_month_valid
    return unless day_of_month

    errors.add(:day_of_month, "must be between 1 and 31") unless day_of_month.between?(1, 31)
  end

  # @return [void]
  def week_of_month_valid
    return unless week_of_month

    errors.add(:week_of_month, "must be between 1 and 5") unless week_of_month.between?(1, 5)
  end

  # @return [void]
  def day_of_week_monthly_valid
    return unless day_of_week_monthly

    errors.add(:day_of_week_monthly, "must be between 0 and 6") unless day_of_week_monthly.between?(0, 6)
  end

  # @return [void]
  def month_of_year_valid
    return unless month_of_year

    errors.add(:month_of_year, "must be between 1 and 12") unless month_of_year.between?(1, 12)
  end

  # @return [void]
  def yearly_day_of_month_required
    errors.add(:day_of_month, "is required for yearly recurrence") if day_of_month.blank?
  end

  # @return [void]
  def master_event_not_a_child
    return unless master_event

    if master_event.recurrent_master_event_id.present?
      errors.add(:master_event, "cannot be a child event from another series")
    end
  end
end
