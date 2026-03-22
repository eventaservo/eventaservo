# frozen_string_literal: true

# Helper methods for displaying event recurrence information.
module EventRecurrencesHelper
  DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  # Returns a human-readable description of a recurrence pattern.
  #
  # @param recurrence [EventRecurrence] the recurrence rule
  # @return [String] description like "Every Tuesday and Thursday"
  def recurrence_description(recurrence)
    case recurrence.frequency
    when "daily"
      (recurrence.interval == 1) ? "Every day" : "Every #{recurrence.interval} days"
    when "weekly"
      days = (recurrence.days_of_week || []).sort.map { |d| DAY_NAMES[d] }
      if recurrence.interval == 1
        "Every #{days.to_sentence}"
      else
        "Every #{recurrence.interval} weeks on #{days.to_sentence}"
      end
    when "monthly"
      if recurrence.week_of_month.present?
        nth = %w[First Second Third Fourth Fifth][recurrence.week_of_month - 1]
        day = DAY_NAMES[recurrence.day_of_week_monthly]
        if recurrence.interval == 1
          "#{nth} #{day} of every month"
        else
          "#{nth} #{day} every #{recurrence.interval} months"
        end
      elsif recurrence.interval == 1
        "Day #{recurrence.day_of_month} of every month"
      else
        "Day #{recurrence.day_of_month} every #{recurrence.interval} months"
      end
    when "yearly"
      month = Date::MONTHNAMES[recurrence.month_of_year]
      if recurrence.interval == 1
        "Every #{month} #{recurrence.day_of_month}"
      else
        "Every #{recurrence.interval} years on #{month} #{recurrence.day_of_month}"
      end
    else
      "Custom recurrence"
    end
  end

  # Returns a Bootstrap badge class for recurrence status.
  #
  # @param recurrence [EventRecurrence] the recurrence rule
  # @return [String] badge HTML
  def recurrence_status_badge(recurrence)
    if recurrence.active?
      content_tag(:span, "Active", class: "badge bg-success")
    else
      content_tag(:span, "Inactive", class: "badge bg-secondary")
    end
  end
end
