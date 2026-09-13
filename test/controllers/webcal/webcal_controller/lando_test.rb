# frozen_string_literal: true

require "test_helper"

class Webcal::WebcalController::LandoTest < ActionDispatch::IntegrationTest
  setup do
    @brazil = countries(:brazil)

    Event.create!(
      title: "Brazilia Esperanto-renkontiĝo",
      description: "Evento en Brazilo",
      city: "San-Paŭlo",
      country_id: @brazil.id,
      date_start: 1.month.from_now,
      date_end: 1.month.from_now + 2.days,
      code: "cxe-br",
      site: "https://example.org/br",
      email: "br@example.org",
      user: users(:user)
    )
  end

  test "country webcal returns ics format" do
    get "/webcal/lando/br.ics"

    assert_response :success
    assert_equal "text/calendar; charset=utf-8", response.content_type
  end

  test "country webcal with unknown country code redirects to root" do
    get "/webcal/lando/zz.ics"

    assert_redirected_to root_url
    assert_equal "Landa kodo ne ekzistas", flash[:notice]
  end

  test "country webcal emits stable UIDs derived from event uuid" do
    get "/webcal/lando/br.ics"
    assert_response :success

    uids = parse_uids_from_ics(response.body)

    events_br = Event.joins(:country).where(countries: {code: "br"})
    events_br.each do |event|
      assert_includes uids, "#{event.uuid}@eventaservo.org"
    end
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
