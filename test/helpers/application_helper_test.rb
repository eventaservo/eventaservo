# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # format_date tests
  test "format_date should default format date to long" do
    date = Date.new(1978, 7, 17)
    assert_equal "lundo, 17 julio 1978", format_date(date)
  end

  # color_event tests
  test "color_event should return gray for past events" do
    assert_equal "gray", color_event(build_stubbed(:event, :past))
  end

  test "color_event should return green for future events" do
    assert_equal "green", color_event(build_stubbed(:event, :future))
  end

  # markdown tests
  test "markdown should return html" do
    assert_equal "<p><strong>PROVO</strong></p>\n", markdown("**PROVO**")
  end

  # page_title tests
  test "page_title should return page title html" do
    assert_equal '<h2 class="text-center">Titolo<small> sub-titolo</small></h2>',
      page_title("Titolo", "sub-titolo")
  end

  # flash_class tests
  test "flash_class should return class color 'primary' for :notice" do
    assert_equal "alert-primary", flash_class(:notice)
  end

  test "flash_class should return class color 'success' for :success" do
    assert_equal "alert-success", flash_class(:success)
  end

  test "flash_class should return class color 'danger' for :error" do
    assert_equal "alert-danger", flash_class(:error)
  end

  test "flash_class should return class color 'warning' for :alert" do
    assert_equal "alert-warning", flash_class(:alert)
  end

  test "flash_class should return class color 'info' for :alia" do
    assert_equal "alert-info", flash_class(:alia)
  end

  # event_date tests
  test "event_date should return formatted event dates" do
    event = create(:evento)
    event.update(time_zone: "Etc/UTC")

    # Samtaga evento
    event.update!(
      date_start: Time.new(2018, 7, 17, 12, 0, 0).in_time_zone(event.time_zone),
      date_end: Time.new(2018, 7, 17, 12, 0, 0).in_time_zone(event.time_zone)
    )
    assert_equal "mardo, 17 julio 2018", event_date(event)

    # sammonata evento
    event.update!(date_end: Time.new(2018, 7, 21, 12, 0, 0).in_time_zone(event.time_zone))
    assert_equal "17 - 21 julio 2018", event_date(event)

    # malsammonata evento
    event.update!(date_end: Time.new(2018, 8, 21, 12, 0, 0).in_time_zone(event.time_zone))
    assert_equal "17 julio - 21 aŭgusto 2018", event_date(event)

    # malsamjara evento
    event.update!(date_end: Time.new(2019, 1, 6, 12, 0, 0).in_time_zone(event.time_zone))
    assert_equal "17 julio 2018 - 6 januaro 2019", event_date(event)
  end

  # event_full_description tests
  test "event_full_description should return the full address for RSS" do
    event = create(:event, :brazila)
    event.date_start = Time.zone.parse("1978-07-17 21:00:00 +03:00")
    event.date_end = event.date_start + 1.hour
    event.description = "Grava tago"
    event.city = "San-Paŭlo"
    event.save!

    assert_equal "lundo, 17 julio 1978 (Brazilo - San-Paŭlo)<br/>Grava tago",
      event_full_description(event)
  end
end
