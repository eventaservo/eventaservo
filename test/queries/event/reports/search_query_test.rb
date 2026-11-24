# frozen_string_literal: true

require "test_helper"

class Event::Reports::SearchQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @valid_event = events(:valid_event)
    @meetup = events(:esperanto_meetup)

    @older_report = Event::Report.create!(
      title: "Kongresa raporto",
      url: "https://example.org/report-1",
      event: @valid_event,
      user: @user,
      created_at: 2.days.ago
    )
    @newer_report = Event::Report.create!(
      title: "Renkontiĝa resumo",
      url: "https://example.org/report-2",
      event: @meetup,
      user: @user,
      created_at: 1.day.ago
    )
  end

  test "returns all reports ordered newest first by default" do
    result = Event::Reports::SearchQuery.new.call

    assert_equal [@newer_report.id, @older_report.id], result.map(&:id)
  end

  test "filters by report title case-insensitively and escapes LIKE metacharacters" do
    result = Event::Reports::SearchQuery.new(title: "kongresa").call
    assert_equal [@older_report], result.to_a

    escaped_result = Event::Reports::SearchQuery.new(title: "Kongresa%raporto").call
    assert_empty escaped_result
  end

  test "filters by associated event title case-insensitively" do
    result = Event::Reports::SearchQuery.new(event_title: "esperanto meetup").call

    assert_equal [@newer_report], result.to_a
  end

  test "combines title and event_title filters" do
    result = Event::Reports::SearchQuery.new(
      title: "raporto",
      event_title: "Rails Conference"
    ).call

    assert_equal [@older_report], result.to_a
  end
end
