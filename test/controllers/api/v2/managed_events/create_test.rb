# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::CreateTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:teacher)
    Users::RegenerateApiToken.call(user: @user)
    @headers = {"Authorization" => "Bearer #{@user.jwt_token}"}
  end

  test "creates an event and returns 201 with JSON payload" do
    payload = {
      title: "API Created Event",
      description: "Created through API v2",
      content: "<p>Welcome everyone</p>",
      date_start: "2026-10-01T14:00:00Z",
      date_end: "2026-10-01T16:00:00Z",
      time_zone: "Etc/UTC",
      email: "organizer@example.org",
      online: true,
      organization_short_names: ["rotterdam_centre"],
      tags: ["Kurso"]
    }

    assert_difference "Event.count", 1 do
      post "/api/v2/events", params: payload, headers: @headers, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "API Created Event", json["title"]
    assert_equal "online", json["format"]
    assert_nil json["location"]
    assert_equal ["Kurso"], json["tags"]
    assert_equal ["rotterdam_centre"], json["organizations"].map { |o| o["short_name"] }
    assert_not_nil json["uuid"]
  end

  test "returns 422 with validation details when payload is invalid" do
    payload = {
      title: "",
      description: "Missing dates and contact"
    }

    assert_no_difference "Event.count" do
      post "/api/v2/events", params: payload, headers: @headers, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert json["details"].key?("title")
  end

  test "returns 401 when unauthenticated" do
    post "/api/v2/events", params: {title: "No Auth"}, as: :json

    assert_response :unauthorized
    assert_equal "Missing authentication token", JSON.parse(response.body)["error"]
  end
end
