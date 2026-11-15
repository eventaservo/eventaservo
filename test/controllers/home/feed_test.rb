# frozen_string_literal: true

require "test_helper"

class HomeController::FeedTest < ActionDispatch::IntegrationTest
  test "should get feed as xml" do
    get events_rss_url
    assert_response :success
    assert_equal "application/xml", response.media_type
  end

  test "should not get feed as md" do
    # When requesting unsupported format, should return 406 Not Acceptable
    get events_rss_url(format: :md)
    assert_response :not_acceptable
  end

  test "should not get feed as html" do
    get events_rss_url(format: :html)
    assert_response :not_acceptable
  end

  test "limits the feed to the nearest upcoming events" do
    travel_to Time.zone.parse("2026-07-01 12:00:00") do
      insert_upcoming_events(HomeController::FEED_LIMIT + 5)

      get events_rss_url

      assert_response :success
      assert_equal HomeController::FEED_LIMIT, response.body.scan("<item>").size
    end
  end

  test "orders the feed by start date" do
    travel_to Time.zone.parse("2026-07-01 12:00:00") do
      Event.delete_all

      later = create(:event, title: "Pli malfrua", short_url: nil,
        date_start: 20.days.from_now, date_end: 20.days.from_now)
      sooner = create(:event, title: "Pli frua", short_url: nil,
        date_start: 3.days.from_now, date_end: 3.days.from_now)

      get events_rss_url

      assert_response :success
      titles = response.body.scan(%r{<title>(.*?)</title>}).flatten
      assert_operator titles.index(sooner.title), :<, titles.index(later.title)
    end
  end

  test "renders an empty feed when there are no upcoming events" do
    Event.delete_all

    get events_rss_url

    assert_response :success
    assert_equal 0, response.body.scan("<item>").size
  end

  test "allows public caches to reuse the feed" do
    get events_rss_url

    assert_response :success
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes response.headers["Cache-Control"], "max-age=#{HomeController::FEED_CACHE_TTL.to_i}"
  end

  test "reuses the cached document instead of rendering it again" do
    with_memory_cache do
      renders = 0
      subscriber = ActiveSupport::Notifications.subscribe("render_template.action_view") do |*, payload|
        renders += 1 if payload[:identifier].to_s.include?("home/feed")
      end

      travel_to Time.zone.parse("2026-07-01 12:00:00") do
        Event.delete_all
        create(:event, title: "Unua titolo", short_url: nil,
          date_start: 5.days.from_now, date_end: 5.days.from_now)

        get events_rss_url
        assert_response :success
        assert_includes response.body, "Unua titolo"
        renders_on_miss = renders
        assert_operator renders_on_miss, :>, 0, "the template must be rendered on a cache miss"
        first_render = response.body

        get events_rss_url
        assert_equal first_render, response.body
        assert_equal renders_on_miss, renders, "a cache hit must not render the template again"
      end
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end

  test "rebuilds the document when an event changes" do
    with_memory_cache do
      travel_to Time.zone.parse("2026-07-01 12:00:00") do
        Event.delete_all
        event = create(:event, title: "Unua titolo", short_url: nil,
          date_start: 5.days.from_now, date_end: 5.days.from_now)

        get events_rss_url
        assert_includes response.body, "Unua titolo"
        first_render = response.body

        travel 1.minute
        event.update!(title: "Dua titolo")

        get events_rss_url
        assert_includes response.body, "Dua titolo"
        assert_not_equal first_render, response.body
      end
    end
  end

  test "rebuilds the document when an event is edited again within the same second" do
    with_memory_cache do
      travel_to Time.zone.parse("2026-07-01 12:00:00.100"), with_usec: true do
        Event.delete_all
        event = create(:event, title: "Unua titolo", short_url: nil,
          date_start: 5.days.from_now, date_end: 5.days.from_now)

        get events_rss_url
        assert_includes response.body, "Unua titolo"

        # Same second, only the fraction changes: a seconds-precision key would not move.
        travel_to Time.zone.parse("2026-07-01 12:00:00.500"), with_usec: true
        event.update!(title: "Dua titolo")

        get events_rss_url
        assert_includes response.body, "Dua titolo", "a sub-second edit must invalidate the cache"
      end
    end
  end

  test "renders the feed in the default locale for every reader" do
    with_memory_cache do
      travel_to Time.zone.parse("2026-07-06 12:00:00") do
        Event.delete_all
        create(:event, title: "Unua titolo", short_url: nil, online: true, city: "Reta",
          date_start: 2.days.from_now, date_end: 2.days.from_now)

        default_label = I18n.t("events.online_event", locale: I18n.default_locale)
        english_label = I18n.t("events.online_event", locale: :en)
        assert_not_equal default_label, english_label, "the labels must differ for this assertion to mean anything"

        sign_in users(:admin_user)
        get events_rss_url(locale: :en)

        assert_response :success
        assert_includes response.body, default_label
        assert_not_includes response.body, english_label

        sign_out users(:admin_user)
        get events_rss_url

        assert_response :success
        assert_includes response.body, default_label
        assert_not_includes response.body, english_label
      end
    end
  end

  private

  # Swaps the cache store for an in-memory one for the duration of the block.
  #
  # @return [void]
  def with_memory_cache
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    yield
  ensure
    Rails.cache = original_cache
  end

  # Bulk-inserts upcoming events without callbacks.
  #
  # Creating this many events through the factory is slow and its random
  # +short_url+ collides ("short link not available"), which made the test flaky.
  #
  # @param count [Integer] number of events to insert
  # @return [void]
  def insert_upcoming_events(count)
    now = Time.current
    rows = Array.new(count) do |index|
      start = 10.days.from_now + index.hours
      {
        title: "Ventontulo #{index}",
        description: "Priskribo de la evento #{index}",
        city: "Brasília",
        country_id: Country.first.id,
        user_id: User.first.id,
        date_start: start,
        date_end: start,
        code: "FEED#{SecureRandom.hex(6)}",
        email: "feed@example.com",
        latitude: -15.79,
        longitude: -47.88,
        time_zone: "Etc/UTC",
        cancelled: false,
        created_at: now,
        updated_at: now
      }
    end

    Event.insert_all(rows)
  end
end
