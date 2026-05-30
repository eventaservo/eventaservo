# frozen_string_literal: true

require "test_helper"

class Events::ByContinentController::ShowTest < ActionDispatch::IntegrationTest
  test "renders calendar for reta continent" do
    get events_by_continent_url(continent: "reta")
    assert_response :success
    assert_select "[data-controller='events-calendar']"
  end

  test "renders calendar turbo frame with today as default date for reta continent" do
    get events_by_continent_url(continent: "reta")
    assert_response :success
    assert_select "turbo-frame[data-date='#{Date.current.iso8601}']"
  end

  test "renders calendar for reta continent with given date param" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "turbo-frame[data-date='2026-06-01']"
  end

  test "prev navigation link points to 7 days before given date for reta continent" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-05-25']"
  end

  test "next navigation link points to 7 days after given date for reta continent" do
    get events_by_continent_url(continent: "reta"), params: {date: "2026-06-01"}
    assert_response :success
    assert_select "a[href*='2026-06-08']"
  end

  test "does not render calendar for non-reta continents" do
    get events_by_continent_url(continent: "europo")
    assert_response :success
    assert_select "[data-controller='events-calendar']", count: 0
  end

  test "pasintaj=1 lists past events on the continent" do
    recent = events(:past_event_danio_recent)
    older = events(:past_event_danio_older)

    get events_by_continent_url(continent: "europo", pasintaj: 1)

    assert_response :success
    assert_match recent.title, response.body
    assert_match older.title, response.body
  end

  test "pasintaj=1 hides the okazantaj/today section" do
    get events_by_continent_url(continent: "europo", pasintaj: 1)
    assert_response :success
    assert_no_match "okazas nuntempe", response.body
  end

  test "redirects to root with notice for invalid continent" do
    get events_by_continent_url(continent: "atlantido")
    assert_redirected_to root_path
    assert_equal "Ne estas eventoj en tiu kontinento", flash[:notice]
  end

  test "redirects to normalized continent path" do
    get events_by_continent_url(continent: "Europo")
    assert_redirected_to controller: "events/by_continent", action: "show", continent: "europo"
  end

  test "renders RSS feed for continent" do
    get events_by_continent_url(continent: "europo", format: :xml)
    assert_response :success
    assert_equal "application/xml", response.media_type
  end

  test "renders default kartaro view for non-reta continent with future events" do
    get events_by_continent_url(continent: "azio"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
    assert_match events(:valid_event).title, response.body
  end

  test "renders with hodiau periodo filter" do
    get events_by_continent_url(continent: "azio", periodo: "hodiau"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
  end

  test "renders with estontece periodo filter" do
    get events_by_continent_url(continent: "azio", periodo: "estontece"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
  end

  test "renders with p7_tagojn periodo filter" do
    get events_by_continent_url(continent: "azio", periodo: "p7_tagojn"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
  end

  test "renders with p30_tagojn periodo filter" do
    get events_by_continent_url(continent: "azio", periodo: "p30_tagojn"),
      headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success
  end
end
