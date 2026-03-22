# frozen_string_literal: true

# Presenter for EventRecurrence display logic.
#
# Generates localized human-readable descriptions and status badges.
#
# @example
#   presenter = EventRecurrencePresenter.new(recurrence: recurrence)
#   presenter.description  # => "Every Tuesday and Thursday"
#   presenter.badge_html   # => '<span class="badge bg-success">Active</span>'
class EventRecurrencePresenter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TranslationHelper

  attr_reader :recurrence

  # @param recurrence [EventRecurrence] the recurrence rule
  def initialize(recurrence:)
    @recurrence = recurrence
  end

  # Returns a human-readable, localized description of the recurrence pattern.
  #
  # @return [String]
  def description
    case recurrence.frequency
    when "daily" then daily_description
    when "weekly" then weekly_description
    when "monthly" then monthly_description
    when "yearly" then yearly_description
    else t("recurrences.description.custom")
    end
  end

  # Returns a Bootstrap badge HTML for the recurrence active/inactive status.
  #
  # @return [String] safe HTML string
  def badge_html
    if recurrence.active?
      content_tag(:span, t("recurrences.info.active"), class: "badge bg-success")
    else
      content_tag(:span, t("recurrences.info.inactive"), class: "badge bg-secondary")
    end
  end

  private

  # @return [Array<String>] localized day names (Sunday..Saturday)
  def day_names
    @day_names ||= t("recurrences.form.day_names")
  end

  # @return [Array<String>] localized ordinals (First..Fifth)
  def ordinals
    @ordinals ||= t("recurrences.form.ordinals")
  end

  # @return [Array<String>] localized month names (January..December)
  def month_names
    @month_names ||= t("recurrences.form.month_names")
  end

  # @return [String]
  def daily_description
    if recurrence.interval == 1
      t("recurrences.description.every_day")
    else
      t("recurrences.description.every_n_days", count: recurrence.interval)
    end
  end

  # @return [String]
  def weekly_description
    days = (recurrence.days_of_week || []).sort.map { |d| day_names[d] }
    if recurrence.interval == 1
      t("recurrences.description.every_weekdays", days: days.to_sentence)
    else
      t("recurrences.description.every_n_weeks_on", count: recurrence.interval, days: days.to_sentence)
    end
  end

  # @return [String]
  def monthly_description
    if recurrence.week_of_month.present?
      nth_weekday_description
    elsif recurrence.interval == 1
      t("recurrences.description.day_of_every_month", day: recurrence.day_of_month)
    else
      t("recurrences.description.day_every_n_months", day: recurrence.day_of_month, count: recurrence.interval)
    end
  end

  # @return [String]
  def nth_weekday_description
    nth = ordinals[recurrence.week_of_month - 1]
    day = day_names[recurrence.day_of_week_monthly]
    if recurrence.interval == 1
      t("recurrences.description.nth_weekday_every_month", nth: nth, day: day)
    else
      t("recurrences.description.nth_weekday_every_n_months", nth: nth, day: day, count: recurrence.interval)
    end
  end

  # @return [String]
  def yearly_description
    month = month_names[recurrence.month_of_year - 1]
    if recurrence.interval == 1
      t("recurrences.description.every_year_on", month: month, day: recurrence.day_of_month)
    else
      t("recurrences.description.every_n_years_on", count: recurrence.interval, month: month, day: recurrence.day_of_month)
    end
  end
end
