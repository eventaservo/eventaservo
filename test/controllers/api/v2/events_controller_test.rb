# frozen_string_literal: true

require "test_helper"

class Api::V2::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @token = @user.jwt_token
  end

  # #index tests
  test "index returns event based on UUID" do
    uuid = SecureRandom.uuid
    create(:event, uuid: uuid)

    get "/api/v2/eventoj", params: {uuid: uuid}, headers: {"Authorization" => "Bearer #{@token}"}

    response_event = JSON.parse(response.body)[0]
    assert_equal uuid, response_event["uuid"]
  end

  test "index returns events based on date range" do
    create(:event, date_start: "1999-01-01", date_end: "1999-01-02")
    create(:event, date_start: "2000-01-01", date_end: "2000-01-02")

    get "/api/v2/eventoj",
      params: {komenca_dato: "1999-01-01", fina_dato: "1999-01-02"},
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_equal 1, JSON.parse(response.body).count
  end

  test "index returns events based on country code" do
    create(:event, country: Country.by_code("US"))
    create(:event, country: Country.by_code("BR"))

    get "/api/v2/eventoj",
      params: {landa_kodo: "BR"},
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_equal 1, JSON.parse(response.body).count
  end

  test "index returns events based on category" do
    create(:event, specolisto: "kurso")
    create(:event, specolisto: "alia speco")

    get "/api/v2/eventoj",
      params: {speco: "kurso"},
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_equal 1, JSON.parse(response.body).count
  end
end
