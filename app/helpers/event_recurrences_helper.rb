# frozen_string_literal: true

# Helper methods for displaying event recurrence information.
module EventRecurrencesHelper
  # Returns a human-readable, localized description of a recurrence pattern.
  #
  # @param recurrence [EventRecurrence] the recurrence rule
  # @return [String] description like "Every Tuesday and Thursday"
  def recurrence_description(recurrence)
    day_names = t("recurrences.form.day_names")
    ordinals = t("recurrences.form.ordinals")
    month_names = t("recurrences.form.month_names")

    case recurrence.frequency
    when "daily"
      if recurrence.interval == 1
        t("recurrences.description.every_day")
      else
        t("recurrences.description.every_n_days", count: recurrence.interval)
      end
    when "weekly"
      days = (recurrence.days_of_week || []).sort.map { |d| day_names[d] }
      if recurrence.interval == 1
        t("recurrences.description.every_weekdays", days: days.to_sentence)
      else
        t("recurrences.description.every_n_weeks_on", count: recurrence.interval, days: days.to_sentence)
      end
    when "monthly"
      if recurrence.week_of_month.present?
        nth = ordinals[recurrence.week_of_month - 1]
        day = day_names[recurrence.day_of_week_monthly]
        if recurrence.interval == 1
          t("recurrences.description.nth_weekday_every_month", nth: nth, day: day)
        else
          t("recurrences.description.nth_weekday_every_n_months", nth: nth, day: day, count: recurrence.interval)
        end
      elsif recurrence.interval == 1
        t("recurrences.description.day_of_every_month", day: recurrence.day_of_month)
      else
        t("recurrences.description.day_every_n_months", day: recurrence.day_of_month, count: recurrence.interval)
      end
    when "yearly"
      month = month_names[recurrence.month_of_year - 1]
      if recurrence.interval == 1
        t("recurrences.description.every_year_on", month: month, day: recurrence.day_of_month)
      else
        t("recurrences.description.every_n_years_on", count: recurrence.interval, month: month, day: recurrence.day_of_month)
      end
    else
      t("recurrences.description.custom")
    end
  end

  # Returns a Bootstrap badge for recurrence status.
  #
  # @param recurrence [EventRecurrence] the recurrence rule
  # @return [String] badge HTML
  def recurrence_status_badge(recurrence)
    if recurrence.active?
      content_tag(:span, t("recurrences.info.active"), class: "badge bg-success")
    else
      content_tag(:span, t("recurrences.info.inactive"), class: "badge bg-secondary")
    end
  end
end
