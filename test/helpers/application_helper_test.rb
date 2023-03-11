# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "skribu la daton plene" do
    date = Date.new(1978, 7, 17)
    assert_equal "lundo, 17 julio 1978", format_date(date)
  end

  test "simpligas la eventajn datojn" do
    event = create(:evento)

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

  test "colorigas la eventojn pasintajn grizaj" do
    assert_equal "gray", color_event(build_stubbed(:evento, :past))
  end

  test "colorigas la eventojn venontajn verdaj" do
    assert_equal "green", color_event(build_stubbed(:evento, :venonta))
  end

  test "markdown funkcias" do
    assert_equal "<p><strong>PROVO</strong></p>\n", markdown("**PROVO**")
  end

  test "paĝ-titolo" do
    assert_equal '<h2 class="text-center">Titolo<small> sub-titolo</small></h2>', page_title("Titolo", "sub-titolo")
  end

  test "flash classes" do
    assert_equal "alert alert-primary alert-dismissible", flash_class(:notice)
    assert_equal "alert alert-success alert-dismissible", flash_class(:success)
    assert_equal "alert alert-danger alert-dismissible", flash_class(:error)
    assert_equal "alert alert-warning alert-dismissible", flash_class(:alert)
    assert_equal "alert alert-info alert-dismissible", flash_class(:alia)
  end

  test "error_handling - ne estas eraroj" do
    assert_nil error_handling(build_stubbed(:evento))
  end

  test "tuta eventa adreso por RSS" do
    event = create(:evento, :brazila)
    event.date_start = Time.zone.parse("1978-07-17 21:00:00 +03:00")
    event.date_end = event.date_start + 1.hour
    event.description = "Grava tago"
    event.city = "San-Paŭlo"
    event.save!

    assert_equal "lundo, 17 julio 1978 (Brazilo - San-Paŭlo)<br/>Grava tago", event_full_description(event)
  end
end
