# frozen_string_literal: true

require "test_helper"

class EventBrowsingAccessibilityTest < ActionDispatch::IntegrationTest
  setup do
    @country = Country.find_by(code: "br") || Country.create!(name: "Brazilo", code: "br", continent: "Sudameriko")
    @event = create(:event, country: @country, city: "Rio de Janeiro")
    @user = create(:user, username: "testuser")
    @organization = create(:organization, short_name: "testorg", country: @country)
  end

  test "by_country page has accessible webcal and rss links" do
    get events_by_country_path(continent: @country.continent.normalized, country_name: @country.name.normalized), headers: {"HTTP_COOKIE" => "vidmaniero=kartaro"}
    assert_response :success

    # Check for RSS link accessibility
    assert_select "a[title='RSS'][aria-label='RSS fluo']"

    # Check for Webcal link accessibility
    assert_select "a[data-target='#webcalModal'][aria-label='Aboni kalendaron']"

    # Check for Webcal Modal accessibility
    assert_select "#webcalModal[aria-labelledby='webcalModalLabel']"
    assert_select "#webcalModalLabel", text: "Aboni kalendaron"
  end

  test "by_continent page has accessible webcal and rss links" do
    # Create a 'reta' continent event for webcal link to appear (logic in view: if params[:continent] == 'reta')

    get events_by_continent_path(continent: "reta"), headers: {"HTTP_COOKIE" => "vidmaniero=kalendaro"}
    assert_response :success

    # Check for RSS link accessibility
    assert_select "a[title='RSS'][aria-label='RSS fluo']"

    # Check for Webcal link accessibility
    assert_select "a[data-target='#webcalModal'][aria-label='Aboni kalendaron']"

    # Check for Webcal Modal accessibility
    assert_select "#webcalModal[aria-labelledby='webcalModalLabel']"
    assert_select "#webcalModalLabel", text: "Aboni kalendaron"
  end

  test "by_username page has accessible webcal link" do
    get events_by_username_path(username: @user.username)
    assert_response :success

    # Check for Webcal link accessibility
    assert_select "a[data-target='#webcalModal'][aria-label='Aboni personan kalendaron']"

    # Check for Webcal Modal accessibility
    assert_select "#webcalModal[aria-labelledby='webcalModalLabel']"
    assert_select "#webcalModalLabel", text: "Aboni personan kalendaron"
  end

  test "organization show page has accessible webcal link" do
    get organization_path(@organization.short_name)
    assert_response :success

    # Check for Webcal link accessibility
    assert_select "a[data-target='#webcalModal'][aria-label='Aboni organizan kalendaron']"

    # Check for Webcal Modal accessibility
    assert_select "#webcalModal[aria-labelledby='webcalModalLabel']"
    assert_select "#webcalModalLabel", text: "Aboni organizan kalendaron"
  end
end
