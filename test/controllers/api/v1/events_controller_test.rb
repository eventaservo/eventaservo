# frozen_string_literal: true

require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @user.update!(authentication_token: "test_token_123")
  end

  test "index with missing params returns error" do
    get "/api/v1/events.json", headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
    assert_response :bad_request
    assert_equal "Mankas datoj aŭ eventa uuid", JSON.parse(response.body)["eraro"]
  end

  test "index with uuid returns event" do
    uuid = SecureRandom.uuid
    create(:event, uuid: uuid)

    get "/api/v1/events.json", params: {uuid: uuid}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
    assert_response :success

    response_event = JSON.parse(response.body)[0]
    assert_equal uuid, response_event["uuid"]
  end

  test "index with invalid date format returns error" do
    get "/api/v1/events.json", params: {komenca_dato: "12-34-56", fina_dato: "12-34-56"}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
    assert_response :bad_request
    assert_equal "Data formato malĝustas", JSON.parse(response.body)["eraro"]
  end

  test "index with valid params returns events" do
    create(:event, date_start: "2023-01-01", date_end: "2023-01-02")

    get "/api/v1/events.json", params: {komenca_dato: "2023-01-01", fina_dato: "2023-01-02"}, headers: {"X-User-Email" => @user.email, "X-User-Token" => @user.authentication_token}
    assert_response :success
    assert_equal 1, JSON.parse(response.body).count
  end
end
