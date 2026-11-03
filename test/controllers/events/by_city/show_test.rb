# frozen_string_literal: true

require "test_helper"

class Events::ByCityController::ShowTest < ActionDispatch::IntegrationTest
  test "pasintaj=1 lists past events for the city" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
  end

  test "pasintaj=1 excludes events from other cities" do
    country = countries(:denmark)
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older) # in a different city

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: recent.city,
      pasintaj: 1)

    assert_response :success
    assert_no_match older.title, response.body
  end

  test "pasintaj=1 orders past events in the city newest first" do
    country = countries(:denmark)
    older = Event.create!(
      title: "Aarhusa Statistika Kunveno",
      description: "Test",
      city: "Kopenhago",
      country: country,
      format: :onsite,
      date_start: Time.zone.parse("2025-01-10 10:00:00"),
      date_end: Time.zone.parse("2025-01-10 12:00:00"),
      code: SecureRandom.hex(6),
      site: "https://example.org/older",
      user: users(:user)
    )
    newer = Event.create!(
      title: "Kopenhaga Nova Kunveno",
      description: "Test",
      city: "Kopenhago",
      country: country,
      format: :onsite,
      date_start: Time.zone.parse("2025-06-10 10:00:00"),
      date_end: Time.zone.parse("2025-06-10 12:00:00"),
      code: SecureRandom.hex(6),
      site: "https://example.org/newer",
      user: users(:user)
    )

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "Kopenhago",
      pasintaj: 1)

    assert_response :success
    assert response.body.index(newer.title) < response.body.index(older.title),
      "Expected the more-recent past event to appear before the older one"
  end

  test "pasintaj=1 hides the today section" do
    country = countries(:denmark)

    get events_by_city_url(continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "Kopenhago",
      pasintaj: 1)

    assert_response :success
    assert_no_match "okazas nuntempe", response.body
  end

  test "redirects to root when country does not exist" do
    get events_by_city_url(continent: "europo", country_name: "neekzistas", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Lando ne ekzistas", flash[:error]
  end

  test "redirects to root for invalid continent" do
    get events_by_city_url(continent: "atlantido", country_name: "danio", city_name: "kopenhago")
    assert_redirected_to root_path
    assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
  end

  test "renders kartaro view for city with future events" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
    assert_match events(:valid_event).title, response.body
  end

  test "sets default view cookie on first visit" do
    get events_by_city_url(continent: "azio",
      country_name: "afganio",
      city_name: "new york")
    assert_response :success
    assert_equal "kartaro", response.cookies["vidmaniero"]
  end

  test "hodiau filter includes evening event for New York visitor" do
    travel_to Time.utc(2026, 8, 14, 12, 0) do
      country = countries(:denmark)
      Event.create!(
        title: "Evening Event Copenhagen",
        description: "Test",
        city: "Kopenhago",
        country: country,
        format: :onsite,
        date_start: Time.zone.parse("2026-08-14 20:00:00"),
        date_end: Time.zone.parse("2026-08-14 21:00:00"),
        time_zone: "America/New_York",
        code: SecureRandom.hex(6),
        site: "https://test.example.com",
        user: users(:user)
      )

      cookies[:horzono] = "America/New_York"
      cookies[:vidmaniero] = "kartoj"
      get events_by_city_url(continent: country.continent.normalized, country_name: country.name.normalized,
        city_name: "kopenhago", periodo: "hodiau")

      assert_response :success
      assert_match(/Evening Event Copenhagen/, response.body)
    end
  end

  test "kartaro view preloads organizations and tags without N+1 queries" do
    country = countries(:denmark)
    events = 3.times.map do |index|
      create(:event,
        city: "Kopenhago",
        country: country,
        date_start: 1.day.from_now + index.days,
        date_end: 2.days.from_now + index.days)
    end
    events.each { |event| event.organizations = [organizations(:rotterdam_centre), organizations(:sat)] }

    assert_no_queries_match(/"organization_events"\."event_id" = \$\d+/) do
      assert_no_queries_match(/"taggings"\."taggable_id" = \$\d+/) do
        get events_by_city_url(continent: country.continent.normalized,
          country_name: country.name.normalized,
          city_name: "Kopenhago"),
          headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
      end
    end

    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(events.first.title)
  end

  test "card view shows nearby events within 50 km marked with Proksima badge" do
    setup_nearby_events

    get_copenhagen

    assert_response :success
    assert_includes response.body, @copenhagen_event.title
    assert_includes response.body, @malmo_event.title
    assert_select ".card", text: /#{@malmo_event.title}/ do
      assert_select ".badge", text: I18n.t("events.nearby")
    end
    assert_select ".card", text: /#{@copenhagen_event.title}/ do
      assert_select ".badge", text: I18n.t("events.nearby"), count: 0
    end
  end

  test "card view excludes cities farther than the 50 km radius" do
    setup_nearby_events

    get_copenhagen

    assert_response :success
    assert_not_includes response.body, @aarhus_event.title
    assert_not_includes response.body, @corner_event.title
    assert_not_includes response.body, @naestved_event.title
  end

  test "card view shows a link to hide nearby events with nearby=0" do
    setup_nearby_events

    get_copenhagen

    assert_response :success
    assert_select "a[href*='nearby=0']", text: I18n.t("events.hide_nearby")
  end

  test "nearby=0 hides nearby events and shows a link to reveal them" do
    setup_nearby_events

    get_copenhagen(nearby: 0)

    assert_response :success
    assert_includes response.body, @copenhagen_event.title
    assert_not_includes response.body, @malmo_event.title
    assert_not_includes response.body, @naestved_event.title
    assert_select "a", text: I18n.t("events.show_nearby")
  end

  test "nearby toggle preserves active filters in the URL" do
    setup_nearby_events

    get_copenhagen(periodo: "estontece", o: "uea", s: "1,2", t: "unutaga")

    assert_response :success
    assert_select "a", text: I18n.t("events.hide_nearby") do |links|
      href = links.first["href"]
      assert_includes href, "nearby=0"
      assert_includes href, "periodo=estontece"
      assert_includes href, "o=uea"
      assert_includes href, "s=1%2C2"
      assert_includes href, "t=unutaga"
    end
  end

  test "filter badge links preserve nearby=0 when nearby events are hidden" do
    setup_nearby_events

    get_copenhagen(nearby: 0)

    assert_response :success
    assert_select "a.badge[href*='nearby=0']"
  end

  test "map view does not include nearby events" do
    setup_nearby_events

    get_copenhagen(view_mode: "mapo")

    assert_response :success
    assert_includes response.body, @copenhagen_event.title
    assert_not_includes response.body, @malmo_event.title
    assert_select "a", text: I18n.t("events.hide_nearby"), count: 0
  end

  test "past events view does not include nearby events" do
    setup_nearby_events

    get_copenhagen(pasintaj: 1)

    assert_response :success
    assert_not_includes response.body, @malmo_event.title
  end

  private

  # Seeds geo-located future events around Copenhagen for nearby-cities integration tests.
  #
  # @return [void]
  def setup_nearby_events
    denmark = countries(:denmark)
    sweden = countries(:sweden)

    @copenhagen_event = create_geo_event(title: "Copenhagen Future Meetup", city: "Kopenhago", country: denmark, latitude: 55.6761, longitude: 12.5683)
    @malmo_event = create_geo_event(title: "Malmo Future Meetup", city: "Malmö", country: sweden, latitude: 55.6050, longitude: 13.0038)
    @naestved_event = create_geo_event(title: "Naestved Future Meetup", city: "Næstved", country: denmark, latitude: 55.2299, longitude: 11.7609)
    @corner_event = create_geo_event(title: "Corner Town Future Meetup", city: "Angulurbo", country: sweden, latitude: 56.6761, longitude: 14.3683)
    @aarhus_event = create_geo_event(title: "Aarhus Future Meetup", city: "Aarhuso", country: denmark, latitude: 56.1629, longitude: 10.2039)
  end

  # Creates an event with explicit coordinates without triggering the test geocoder stub.
  #
  # @param title [String] Event title
  # @param city [String] City name
  # @param country [Country] Country record
  # @param latitude [Float] Latitude coordinate
  # @param longitude [Float] Longitude coordinate
  #
  # @return [Event]
  def create_geo_event(title:, city:, country:, latitude:, longitude:)
    event = Event.new(
      title: title,
      description: "Test event",
      city: city,
      country: country,
      date_start: 1.month.from_now,
      date_end: 1.month.from_now + 1.day,
      time_zone: "Etc/UTC",
      code: SecureRandom.hex(6),
      site: "https://example.org",
      latitude: latitude,
      longitude: longitude,
      user: users(:user)
    )
    event.instance_variable_set(:@created_from_factory, true)
    event.save!
    event
  end

  # Sends a GET request to the Copenhagen city page with the given view mode and query parameters.
  #
  # @param view_mode [String] Cookie value for +vidmaniero+
  # @param query_params [Hash] Additional query parameters
  #
  # @return [void]
  def get_copenhagen(view_mode: "kartaro", **query_params)
    country = countries(:denmark)
    get events_by_city_url(
      continent: country.continent.normalized,
      country_name: country.name.normalized,
      city_name: "kopenhago",
      **query_params
    ), headers: {"HTTP_COOKIE" => "vidmaniero=#{view_mode}"}
  end
end
