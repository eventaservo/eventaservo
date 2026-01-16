# frozen_string_literal: true

require "test_helper"

# Integration tests for the API v2 error handling.
#
# Tests the catch-all route that returns friendly JSON error messages
# when users access invalid API v2 endpoints.
class Api::V2::ApiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    # Generate JWT token for the test user
    payload = {id: @user.id}
    @token = JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret), "HS256")
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
    assert_equal "Token mankas", JSON.parse(response.body)["eraro"]
  end

  test "tracks event when token is missing" do
    # Mock the tracker to verify the track call
    tracker = Minitest::Mock.new
    tracker.expect(:track, nil, ["Token missing", {kind: "api"}])

    Ahoy::Tracker.stub(:new, tracker) do
      get "/api/v2/eventoj"
    end

    tracker.verify
  end

  test "returns unauthorized when token is invalid" do
    get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "invalid_token"}

    assert_response :unauthorized
    assert_equal "Token ne validas", JSON.parse(response.body)["eraro"]
  end

  test "tracks event when token is invalid" do
    # Mock the tracker to verify the track call
    tracker = Minitest::Mock.new
    tracker.expect(:track, nil, ["Token invalid", {kind: "api"}])

    Ahoy::Tracker.stub(:new, tracker) do
      get "/api/v2/eventoj", headers: {HTTP_AUTHORIZATION: "invalid_token"}
    end

    tracker.verify
  end

  test "returns success when valid token is provided in Authorization header" do
    user = create(:user)
    user.send(:generate_jwt_token)
    user.save!

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
    user.send(:generate_jwt_token)
    user.save!

    create(:evento, date_start: Time.zone.yesterday, date_end: Time.zone.tomorrow)

    get "/api/v2/eventoj",
      params: {
        user_token: user.jwt_token,
        komenca_dato: Time.zone.today.strftime("%Y-%m-%d"),
        fina_dato: (Time.zone.today + 1.year).strftime("%Y-%m-%d")
      }

    assert_response :success
  end
end
