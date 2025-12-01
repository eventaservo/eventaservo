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
end
