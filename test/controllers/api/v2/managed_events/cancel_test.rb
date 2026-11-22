# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::CancelTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    Users::RegenerateApiToken.call(user: @owner)
    @owner_headers = {"Authorization" => "Bearer #{@owner.jwt_token}"}
    @event = events(:valid_event)
  end

  test "cancels event with reason when user is owner" do
    post "/api/v2/events/#{@event.uuid}/cancel",
      params: {cancel_reason: "Severe weather"},
      headers: @owner_headers,
      as: :json

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal true, json["cancelled"]
    assert_equal "Severe weather", json["cancel_reason"]
    assert @event.reload.cancelled?
  end

  test "returns 403 when user is not authorized" do
    other_user = users(:speaker)
    Users::RegenerateApiToken.call(user: other_user)

    post "/api/v2/events/#{@event.uuid}/cancel",
      params: {cancel_reason: "Nope"},
      headers: {"Authorization" => "Bearer #{other_user.jwt_token}"},
      as: :json

    assert_response :forbidden
    assert_not @event.reload.cancelled?
  end
end
