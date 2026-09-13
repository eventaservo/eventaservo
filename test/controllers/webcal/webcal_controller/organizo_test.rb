# frozen_string_literal: true

require "test_helper"

class Webcal::WebcalController::OrganizoTest < ActionDispatch::IntegrationTest
  setup do
    @country = countries(:afghanistan)
    @org = Organization.create!(name: "UEA", short_name: "uea", country: @country)
    @event = Event.create!(
      title: "UEA Kongreso",
      description: "Universala Kongreso",
      city: "Londono",
      country_id: @country.id,
      date_start: 1.month.from_now,
      date_end: 1.month.from_now + 3.days,
      code: "uea-kongreso",
      email: "kongreso@example.org",
      user: users(:user)
    )
    @event.organization_events.create!(organization: @org)
  end

  test "organization webcal returns ics format with stable event UID" do
    get webcal_organizo_url(short_name: "uea", format: :ics)

    assert_response :success
    assert_equal "text/calendar; charset=utf-8", response.content_type
    assert_includes response.body, "UID:#{@event.uuid}@eventaservo.org"
  end

  test "organization webcal with unknown short name redirects to root" do
    get webcal_organizo_url(short_name: "neekzistas", format: :ics)

    assert_redirected_to root_url
    assert_equal "Organizo ne ekzistas", flash[:error]
  end
end
