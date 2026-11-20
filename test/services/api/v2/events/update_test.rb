# frozen_string_literal: true

require "test_helper"

class Api::V2::Events::UpdateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:user)
    @event = events(:valid_event)
    @event.tags << tags(:kurso) unless @event.tags.include?(tags(:kurso))
  end

  test "updates only provided fields and preserves omitted associations" do
    result = nil
    assert_enqueued_with(job: EventoGhisdatigitaJob) do
      assert_difference "Log.count", 1 do
        result = Api::V2::Events::Update.call(
          event: @event,
          user: @user,
          params: {title: "Updated Conference Title"}
        )
      end
    end

    assert result.success?
    assert_equal "Updated Conference Title", result.payload.title
    assert_includes result.payload.tags.pluck(:name), "Kurso"
  end

  test "clears category and characteristic tags when empty array is sent" do
    result = Api::V2::Events::Update.call(
      event: @event,
      user: @user,
      params: {tags: []}
    )

    assert result.success?
    assert_empty result.payload.tags.where(group_name: %w[category characteristic])
  end

  test "returns forbidden when user cannot edit event" do
    other_user = users(:speaker)

    result = Api::V2::Events::Update.call(
      event: @event,
      user: other_user,
      params: {title: "Hijacked"}
    )

    assert result.failure?
    assert_equal :forbidden, result.error
  end

  test "allows organization member to update event" do
    @event.organizations << organizations(:rotterdam_centre)
    member = users(:speaker)

    result = Api::V2::Events::Update.call(
      event: @event,
      user: member,
      params: {description: "Updated by organization member"}
    )

    assert result.success?
    assert_equal "Updated by organization member", result.payload.description
  end

  test "fails with 422 errors on invalid ISO 8601 date" do
    result = Api::V2::Events::Update.call(
      event: @event,
      user: @user,
      params: {date_start: "not-a-date"}
    )

    assert result.failure?
    assert_includes result.error[:date_start], "must be a valid ISO 8601 datetime"
  end
end
