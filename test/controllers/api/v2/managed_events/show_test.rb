# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::ShowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:speaker)
    Users::RegenerateApiToken.call(user: @user)
    @headers = {"Authorization" => "Bearer #{@user.jwt_token}"}
  end

  test "returns any non-deleted event by uuid" do
    event = events(:valid_event)

    get "/api/v2/events/#{event.uuid}", headers: @headers

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal event.uuid, json["uuid"]
    assert_equal event.title, json["title"]
    assert_equal event.code, json["code"]
    assert_equal event.user.name, json["organizer"]
  end

  test "returns 404 when event does not exist" do
    get "/api/v2/events/#{SecureRandom.uuid}", headers: @headers

    assert_response :not_found
    assert_equal "Event not found", JSON.parse(response.body)["error"]
  end

  test "returns 404 when uuid format is invalid" do
    get "/api/v2/events/not-a-valid-uuid", headers: @headers

    assert_response :not_found
    assert_equal "Event not found", JSON.parse(response.body)["error"]
  end

  test "returns 404 when event is soft-deleted" do
    event = events(:valid_event)
    event.update!(deleted: true)

    get "/api/v2/events/#{event.uuid}", headers: @headers

    assert_response :not_found
    assert_equal "Event not found", JSON.parse(response.body)["error"]
  end
end
