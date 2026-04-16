# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  # format_date tests
  test "format_date should default format date to long" do
    date = Date.new(1978, 7, 17)
    assert_equal "lundo, 17 julio 1978", format_date(date)
  end

  test "format_date with short style should return day/month/year" do
    date = Date.new(2026, 3, 8)
    assert_equal "8/mar/26", format_date(date, style: :short)
  end

  test "format_date with compact style should return uppercase day month year" do
    date = Date.new(2026, 3, 8)
    assert_equal "8 MAR 26", format_date(date, style: :compact)
  end

  test "format_date with month_year style should return month and year" do
    date = Date.new(2026, 3, 8)
    assert_equal "marto 2026", format_date(date, style: :month_year)
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

    # sammonata evento
    event.update!(date_end: Time.new(2018, 8, 21, 12, 0, 0).in_time_zone(event.time_zone))
    assert_equal "17 julio - 21 aŭgusto 2018", event_date(event)

    # malsamjara evento
    event.update!(date_end: Time.new(2019, 1, 6, 12, 0, 0).in_time_zone(event.time_zone))
    assert_equal "17 julio 2018 - 6 januaro 2019", event_date(event)
  end

  # flag_icon tests
  test "flag_icon renders a span with fi classes for a string country code" do
    result = flag_icon("br")

    assert_equal '<span class="fi fi-br"></span>', result
  end

  test "flag_icon renders a span with fi classes for a symbol country code" do
    result = flag_icon(:gb)

    assert_equal '<span class="fi fi-gb"></span>', result
  end

  test "flag_icon upcases country code correctly" do
    result = flag_icon("BR")

    assert_equal '<span class="fi fi-br"></span>', result
  end

  test "flag_icon adds fis class when squared is true" do
    result = flag_icon("br", squared: true)

    assert_equal '<span class="fi fi-br fis"></span>', result
  end

  # montras_flagon tests
  test "montras_flagon renders flag for a country" do
    country = countries(:country_1)

    result = montras_flagon(country)

    assert_equal '<span class="fi fi-af"></span>', result
  end

  test "montras_flagon returns nil when country is nil" do
    result = montras_flagon(nil)

    assert_nil result
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

  # rss_enclosure tests
  test "rss_enclosure should use url_for for images" do
    event = events(:valid_event)

    blob_mock = Minitest::Mock.new
    blob_mock.expect :image?, true

    variant_mock = Minitest::Mock.new
    variant_mock.expect :processed, variant_mock

    upload_mock = Object.new
    def upload_mock.blob
      @blob
    end

    def upload_mock.blob=(b)
      @blob = b
    end
    upload_mock.blob = blob_mock
    def upload_mock.variant(args)
      @variant_args = args
      @variant_mock
    end

    def upload_mock.variant_mock=(v)
      @variant_mock = v
    end
    upload_mock.variant_mock = variant_mock
    def upload_mock.variant_args
      @variant_args
    end

    def upload_mock.byte_size
      1000
    end

    def upload_mock.content_type
      "image/jpeg"
    end

    uploads_mock = Minitest::Mock.new
    uploads_mock.expect :attached?, true
    uploads_mock.expect :first, upload_mock

    xml_mock = Object.new
    def xml_mock.enclosure(**kwargs)
      @enclosure_kwargs = kwargs
    end

    def xml_mock.enclosure_kwargs
      @enclosure_kwargs
    end

    stub(:url_for, "http://test.host/proxy") do
      event.stub :uploads, uploads_mock do
        rss_enclosure(xml_mock, event)
      end
    end

    assert_equal({url: "http://test.host/proxy", length: 100, type: "image/jpeg"}, xml_mock.enclosure_kwargs)
    assert_equal({resize_to_limit: [150, 150]}, upload_mock.variant_args)

    blob_mock.verify
    variant_mock.verify
    uploads_mock.verify
  end
end
