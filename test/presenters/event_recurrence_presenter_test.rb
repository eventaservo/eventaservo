# frozen_string_literal: true

require "test_helper"

class EventRecurrencePresenterTest < ActiveSupport::TestCase
  # -- #description: daily --

  test "#description for daily interval 1" do
    recurrence = build_recurrence(frequency: "daily", interval: 1)
    assert_equal I18n.t("recurrences.description.every_day"), presenter(recurrence).description
  end

  test "#description for daily interval 3" do
    recurrence = build_recurrence(frequency: "daily", interval: 3)
    assert_equal I18n.t("recurrences.description.every_n_days", count: 3), presenter(recurrence).description
  end

  # -- #description: weekly --

  test "#description for weekly single day" do
    recurrence = build_recurrence(frequency: "weekly", interval: 1, days_of_week: [1])
    day_names = I18n.t("recurrences.form.day_names")
    expected = I18n.t("recurrences.description.every_weekdays", days: day_names[1])
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for weekly multiple days" do
    recurrence = build_recurrence(frequency: "weekly", interval: 1, days_of_week: [2, 4])
    day_names = I18n.t("recurrences.form.day_names")
    days_text = [day_names[2], day_names[4]].to_sentence
    expected = I18n.t("recurrences.description.every_weekdays", days: days_text)
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for weekly with interval" do
    recurrence = build_recurrence(frequency: "weekly", interval: 2, days_of_week: [1])
    day_names = I18n.t("recurrences.form.day_names")
    expected = I18n.t("recurrences.description.every_n_weeks_on", count: 2, days: day_names[1])
    assert_equal expected, presenter(recurrence).description
  end

  # -- #description: monthly --

  test "#description for monthly fixed day" do
    recurrence = build_recurrence(frequency: "monthly", interval: 1, day_of_month: 15)
    expected = I18n.t("recurrences.description.day_of_every_month", day: 15)
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for monthly fixed day with interval" do
    recurrence = build_recurrence(frequency: "monthly", interval: 2, day_of_month: 10)
    expected = I18n.t("recurrences.description.day_every_n_months", day: 10, count: 2)
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for monthly nth weekday" do
    recurrence = build_recurrence(frequency: "monthly", interval: 1, week_of_month: 1, day_of_week_monthly: 6)
    ordinals = I18n.t("recurrences.form.ordinals")
    day_names = I18n.t("recurrences.form.day_names")
    expected = I18n.t("recurrences.description.nth_weekday_every_month", nth: ordinals[0], day: day_names[6])
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for monthly nth weekday with interval" do
    recurrence = build_recurrence(frequency: "monthly", interval: 3, week_of_month: 2, day_of_week_monthly: 3)
    ordinals = I18n.t("recurrences.form.ordinals")
    day_names = I18n.t("recurrences.form.day_names")
    expected = I18n.t("recurrences.description.nth_weekday_every_n_months", nth: ordinals[1], day: day_names[3], count: 3)
    assert_equal expected, presenter(recurrence).description
  end

  # -- #description: yearly --

  test "#description for yearly" do
    recurrence = build_recurrence(frequency: "yearly", interval: 1, month_of_year: 7, day_of_month: 17)
    month_names = I18n.t("recurrences.form.month_names")
    expected = I18n.t("recurrences.description.every_year_on", month: month_names[6], day: 17)
    assert_equal expected, presenter(recurrence).description
  end

  test "#description for yearly with interval" do
    recurrence = build_recurrence(frequency: "yearly", interval: 4, month_of_year: 2, day_of_month: 29)
    month_names = I18n.t("recurrences.form.month_names")
    expected = I18n.t("recurrences.description.every_n_years_on", count: 4, month: month_names[1], day: 29)
    assert_equal expected, presenter(recurrence).description
  end

  # -- #badge_html --

  test "#badge_html for active recurrence" do
    recurrence = build_recurrence(frequency: "daily", interval: 1)
    recurrence.active = true
    html = presenter(recurrence).badge_html

    assert_includes html, "badge bg-success"
    assert_includes html, I18n.t("recurrences.info.active")
  end

  test "#badge_html for inactive recurrence" do
    recurrence = build_recurrence(frequency: "daily", interval: 1)
    recurrence.active = false
    html = presenter(recurrence).badge_html

    assert_includes html, "badge bg-secondary"
    assert_includes html, I18n.t("recurrences.info.inactive")
  end

  private

  # @param recurrence [EventRecurrence]
  # @return [EventRecurrencePresenter]
  def presenter(recurrence)
    EventRecurrencePresenter.new(recurrence:)
  end

  # @param attrs [Hash]
  # @return [EventRecurrence]
  def build_recurrence(**attrs)
    EventRecurrence.new(
      frequency: attrs[:frequency] || "daily",
      interval: attrs[:interval] || 1,
      days_of_week: attrs[:days_of_week] || [],
      day_of_month: attrs[:day_of_month],
      week_of_month: attrs[:week_of_month],
      day_of_week_monthly: attrs[:day_of_week_monthly],
      month_of_year: attrs[:month_of_year],
      end_type: "never",
      active: true
    )
  end
end
