# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::UpdateTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    Users::RegenerateApiToken.call(user: @owner)
    @owner_headers = {"Authorization" => "Bearer #{@owner.jwt_token}"}
    @event = events(:valid_event)
  end

  test "updates event when authenticated user is owner" do
    patch "/api/v2/events/#{@event.uuid}",
      params: {title: "New Title via PATCH", description: "Updated description"},
      headers: @owner_headers,
      as: :json

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal "New Title via PATCH", json["title"]
    assert_equal "Updated description", json["description"]
    assert_equal "New Title via PATCH", @event.reload.title
  end

  test "supports PUT as alias for PATCH" do
    put "/api/v2/events/#{@event.uuid}",
      params: {title: "New Title via PUT"},
      headers: @owner_headers,
      as: :json

    assert_response :ok
    assert_equal "New Title via PUT", @event.reload.title
  end

  test "allows organization member to update event" do
    @event.organizations << organizations(:rotterdam_centre)
    member = users(:speaker)
    Users::RegenerateApiToken.call(user: member)

    patch "/api/v2/events/#{@event.uuid}",
      params: {title: "Org Member Update"},
      headers: {"Authorization" => "Bearer #{member.jwt_token}"},
      as: :json

    assert_response :ok
    assert_equal "Org Member Update", @event.reload.title
  end

  test "returns 403 when user is not authorized to edit event" do
    other_user = users(:speaker)
    Users::RegenerateApiToken.call(user: other_user)

    patch "/api/v2/events/#{@event.uuid}",
      params: {title: "Unauthorized Update"},
      headers: {"Authorization" => "Bearer #{other_user.jwt_token}"},
      as: :json

    assert_response :forbidden
    assert_equal "You are not authorized to perform this action", JSON.parse(response.body)["error"]
  end

  test "returns 422 when updating with invalid tag" do
    patch "/api/v2/events/#{@event.uuid}",
      params: {tags: ["InvalidTagName"]},
      headers: @owner_headers,
      as: :json

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert json["details"].key?("tags")
  end
end
