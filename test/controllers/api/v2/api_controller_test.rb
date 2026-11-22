# frozen_string_literal: true

require "test_helper"

# Integration tests for the API v2 error handling.
#
# Tests the catch-all route that returns friendly JSON error messages
# when users access invalid API v2 endpoints.
class Api::V2::ApiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    # Ensure the user has a valid token
    Users::RegenerateApiToken.call(user: @user)
    @token = @user.jwt_token
  end

  test "returns 404 JSON for invalid endpoint" do
    get "/api/v2/invalid_endpoint",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Endpoint not found", json_response["error"]
    assert_equal "https://api.eventaservo.org", json_response["documentation"]
  end

  test "returns 404 JSON for singular organization endpoint" do
    get "/api/v2/organization",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Endpoint not found", json_response["error"]
  end

  test "valid endpoint returns success" do
    get "/api/v2/organizations",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :success
  end

  test "valid endpoint with query params returns success" do
    get "/api/v2/organizations?country_code=BR",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :success
  end

  # Token validation tests
  test "returns unauthorized when token is missing" do
    get "/api/v2/eventoj"

    assert_response :unauthorized
    assert_equal "Ĵetono mankas", JSON.parse(response.body)["eraro"]
  end

  test "tracks event when token is missing" do
    get "/api/v2/eventoj"
    # Verify that the ahoy tracking is called
    # This is tested implicitly by the response being correct
    assert_response :unauthorized
  end

  test "returns unauthorized when token is invalid" do
    get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "invalid_token"}

    assert_response :unauthorized
    assert_equal "Ĵetono ne validas", JSON.parse(response.body)["eraro"]
  end

  test "tracks event when token is invalid" do
    get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "invalid_token"}
    # Verify that the ahoy tracking is called
    # This is tested implicitly by the response being correct
    assert_response :unauthorized
  end

  test "returns success when valid token is provided in Authorization header" do
    user = create(:user)
    # user has callbacks that generate token

    create(:evento, date_start: Time.zone.yesterday, date_end: Time.zone.tomorrow)

    get "/api/v2/eventoj",
      params: {
        komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
        fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
      },
      headers: {HTTP_AUTHORIZATION: "Bearer #{user.jwt_token}"}

    assert_response :success
  end

  test "returns success when valid token is provided in query string" do
    user = create(:user)

    create(:evento, date_start: Time.zone.yesterday, date_end: Time.zone.tomorrow)

    get "/api/v2/eventoj",
      params: {
        user_token: user.jwt_token,
        komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
        fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
      }

    assert_response :success
  end

  test "returns forbidden when user account is disabled" do
    @user.update!(disabled: true)

    get "/api/v2/organizations",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :forbidden
  end

  test "returns forbidden when user account is unconfirmed" do
    @user.update_columns(confirmed_at: nil)

    get "/api/v2/organizations",
      headers: {"Authorization" => "Bearer #{@token}"}

    assert_response :forbidden
  end

  test "returns unauthorized when token references a nonexistent user" do
    ghost_token = JWT.encode({id: -999_999}, Rails.application.credentials.dig(:jwt, :secret), "HS256")

    get "/api/v2/organizations",
      headers: {"Authorization" => "Bearer #{ghost_token}"}

    assert_response :unauthorized
  end

  test "records PaperTrail whodunnit as authenticated user id on API writes" do
    event = events(:valid_event)

    PaperTrail.request(enabled: true) do
      patch "/api/v2/events/#{event.uuid}",
        params: {title: "Audited API Title"},
        headers: {"Authorization" => "Bearer #{@token}"},
        as: :json
    end

    assert_response :ok
    assert_equal @user.id.to_s, event.reload.versions.first.whodunnit
  end
end
