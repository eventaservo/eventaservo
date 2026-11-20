# frozen_string_literal: true

require "test_helper"

class Api::V2::ManagedEventsController::DestroyTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:user)
    Users::RegenerateApiToken.call(user: @owner)
    @owner_headers = {"Authorization" => "Bearer #{@owner.jwt_token}"}
    @event = events(:valid_event)
  end

  test "soft-deletes event and returns 204 when user is owner" do
    delete "/api/v2/events/#{@event.uuid}", headers: @owner_headers

    assert_response :no_content
    assert Event.unscoped.find(@event.id).deleted?
  end

  test "returns 403 when user is not authorized" do
    other_user = users(:speaker)
    Users::RegenerateApiToken.call(user: other_user)

    delete "/api/v2/events/#{@event.uuid}",
      headers: {"Authorization" => "Bearer #{other_user.jwt_token}"}

    assert_response :forbidden
    assert_not Event.unscoped.find(@event.id).deleted?
  end

  test "returns 404 when event does not exist" do
    delete "/api/v2/events/#{SecureRandom.uuid}", headers: @owner_headers

    assert_response :not_found
  end
end
