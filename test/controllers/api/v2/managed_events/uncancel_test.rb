# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::UncancelTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    Users::RegenerateApiToken.call(user: @owner)
    @owner_headers = {"Authorization" => "Bearer #{@owner.jwt_token}"}
    @event = events(:valid_event)
    @event.update!(cancelled: true, cancel_reason: "Temporary issue")
  end

  test "uncancels event and clears cancel_reason when user is owner" do
    post "/api/v2/events/#{@event.uuid}/uncancel",
      headers: @owner_headers,
      as: :json

    assert_response :ok
    json = JSON.parse(response.body)
    assert_equal false, json["cancelled"]
    assert_nil json["cancel_reason"]
    assert_not @event.reload.cancelled?
  end

  test "returns 403 when user is not authorized" do
    other_user = users(:speaker)
    Users::RegenerateApiToken.call(user: other_user)

    post "/api/v2/events/#{@event.uuid}/uncancel",
      headers: {"Authorization" => "Bearer #{other_user.jwt_token}"},
      as: :json

    assert_response :forbidden
    assert @event.reload.cancelled?
  end
end
