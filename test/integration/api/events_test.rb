# frozen_string_literal: true

require "test_helper"

class Api::EventsTest < ActionDispatch::IntegrationTest
  test "GET /api/v1/events.json returns a list of events" do
    create(:event, :brazila)
    user = users(:user)

    get "/api/v1/events.json",
      params: {
        user_email: user.email, user_token: user.authentication_token,
        komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
        fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
      }

    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_equal Event.last.title, json.first["titolo"]
  end

  test "GET /api/v2/eventoj with UUID returns only one record" do
    event = create(:evento)
    user = users(:user)
    Users::RegenerateApiToken.call(user: user)

    get "/api/v2/eventoj", headers: {Authorization: user.reload.jwt_token}, params: {uuid: event.uuid}

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.count
    assert_equal event.title, json.first["titolo"]
  end
end
