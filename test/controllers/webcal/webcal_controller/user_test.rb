# frozen_string_literal: true

require "test_helper"

class Webcal::WebcalController::UserTest < ActionDispatch::IntegrationTest
  test "user webcal returns ics format for valid user" do
    user = users(:user)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)

    assert_response :success
    assert_equal "text/calendar; charset=utf-8", response.content_type
  end

  test "same event has the same UID across two sequential GETs" do
    user = users(:user)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success
    uids_first = parse_uids_from_ics(response.body)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success
    uids_second = parse_uids_from_ics(response.body)

    assert_equal uids_first, uids_second
    assert_not_empty uids_first
  end

  test "different events have different UIDs" do
    user = users(:user)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success

    uids = parse_uids_from_ics(response.body)
    assert_operator uids.size, :>, 1
    assert_equal uids.size, uids.uniq.size
  end

  test "UID matches the expected format evento.uuid@eventaservo.org" do
    user = users(:user)
    eventos = user.events.reload

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success

    uids = parse_uids_from_ics(response.body)
    expected_uids = eventos.map { |e| "#{e.uuid}@eventaservo.org" }

    expected_uids.each do |expected_uid|
      assert_includes uids, expected_uid,
        "Expected UID #{expected_uid} not found in ICS output"
    end
  end

  test "ICS events contain last-modified, sequence and categories properties" do
    user = users(:user)
    meetup = events(:esperanto_meetup)

    get webcal_user_url(webcal_token: user.webcal_token, format: :ics)
    assert_response :success

    cal = Icalendar::Calendar.parse(response.body).first

    cal.events.each do |event|
      assert event.last_modified.present?,
        "Expected LAST-MODIFIED to be present on event #{event.uid}"
      assert event.sequence.present?,
        "Expected SEQUENCE to be present on event #{event.uid}"
    end

    meetup_event = cal.events.find { |event| event.uid == "#{meetup.uuid}@eventaservo.org" }
    assert meetup_event.present?, "Expected #{meetup.uuid}@eventaservo.org in the ICS output"
    assert_equal meetup.tags.categories.map(&:name), meetup_event.categories
  end

  private

  # Parses UID values from raw ICS text.
  #
  # @param ics_text [String] Raw ICS calendar body
  # @return [Array<String>] List of UID values
  def parse_uids_from_ics(ics_text)
    ics_text.scan(/^UID:(.+)$/i).flatten.map(&:strip)
  end
end
