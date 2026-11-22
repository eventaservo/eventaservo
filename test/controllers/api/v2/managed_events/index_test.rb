# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    Users::RegenerateApiToken.call(user: @user)
    @headers = {"Authorization" => "Bearer #{@user.jwt_token}"}
  end

  test "returns paginated list of events manageable by authenticated user" do
    event = events(:valid_event)

    get "/api/v2/events", headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_includes json["events"].map { |e| e["uuid"] }, event.uuid
    assert_equal 1, json["meta"]["page"]
    assert_equal 20, json["meta"]["per_page"]
    assert_operator json["meta"]["total_count"], :>=, 1
  end

  test "respects per_page parameter" do
    get "/api/v2/events", params: {per_page: 5}, headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal 5, json["meta"]["per_page"]
  end

  test "returns 401 with English error key when token is missing" do
    get "/api/v2/events"

    assert_response :unauthorized
    json = JSON.parse(response.body)
    assert_equal "Missing authentication token", json["error"]
  end

  test "returns 403 when user account is disabled" do
    @user.update!(disabled: true)

    get "/api/v2/events", headers: @headers

    assert_response :forbidden
    json = JSON.parse(response.body)
    assert_equal "Account is disabled or unconfirmed", json["error"]
  end
end
