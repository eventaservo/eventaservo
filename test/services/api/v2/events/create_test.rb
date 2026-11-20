# frozen_string_literal: true

require "test_helper"

class Api::V2::Events::CreateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:teacher)
  end

  test "creates onsite event with valid attributes, organizations, and tags" do
    params = {
      title: "Esperanto Congress",
      description: "Annual gathering of Esperantists",
      content: "<p>Full schedule</p>",
      date_start: "2026-08-01T09:00:00+02:00",
      date_end: "2026-08-03T18:00:00+02:00",
      time_zone: "Europe/Amsterdam",
      site: "https://example.org/congress",
      email: "info@example.org",
      city: "Rotterdam",
      country_code: "AF",
      online: false,
      organization_short_names: ["rotterdam_centre"],
      tags: ["Kurso", "Por junuloj"]
    }

    result = nil
    assert_enqueued_with(job: NovaEventaSciigoJob) do
      assert_difference ["Event.count", "Log.count"], 1 do
        result = Api::V2::Events::Create.call(user: @user, params:)
      end
    end

    assert result.success?
    event = result.payload
    assert_present_uuid(event.uuid)
    assert_equal @user, event.user
    assert_equal "onsite", event.format
    assert_equal countries(:afghanistan), event.country
    assert_equal ["rotterdam_centre"], event.organizations.pluck(:short_name)
    assert_includes event.tags.pluck(:name), "Kurso"
    assert_includes event.tags.pluck(:name), "Por junuloj"
    assert_includes event.enhavo.to_s, "Full schedule"
  end

  test "creates purely online event without city or country_code and preserves seconds" do
    params = {
      title: "Online Esperanto Cafe",
      description: "Weekly online conversation",
      date_start: "2026-09-10T19:00:45",
      date_end: "2026-09-10T21:30:15",
      time_zone: "America/Sao_Paulo",
      email: "cafe@example.org",
      online: true
    }

    result = Api::V2::Events::Create.call(user: @user, params:)

    assert result.success?
    event = result.payload
    assert event.online?
    assert_equal "online", event.format
    assert_equal "Reta", event.city
    assert_equal 99_999, event.country_id
    assert_equal "19:00:45", event.date_start.in_time_zone("America/Sao_Paulo").strftime("%H:%M:%S")
    assert_equal "21:30:15", event.date_end.in_time_zone("America/Sao_Paulo").strftime("%H:%M:%S")
  end

  test "creates hybrid event when online is true with city and country_code" do
    params = {
      title: "Hybrid Meetup",
      description: "Both in-person and online",
      date_start: "2026-09-12T10:00:00Z",
      date_end: "2026-09-12T12:00:00Z",
      site: "https://example.org/hybrid",
      city: "Rotterdam",
      country_code: "af",
      online: true
    }

    result = Api::V2::Events::Create.call(user: @user, params:)

    assert result.success?
    assert_equal "hybrid", result.payload.format
  end

  test "fails with invalid country_code" do
    params = {
      title: "Bad Country Event",
      description: "Description",
      date_start: "2026-09-12T10:00:00Z",
      date_end: "2026-09-12T12:00:00Z",
      site: "https://example.org",
      city: "Rotterdam",
      country_code: "ZZ"
    }

    result = Api::V2::Events::Create.call(user: @user, params:)

    assert result.failure?
    assert_includes result.error[:country_code], "is not a valid country code"
  end

  test "fails when non-admin user attaches organization they do not belong to" do
    params = {
      title: "Unauthorized Org Event",
      description: "Description",
      date_start: "2026-09-12T10:00:00Z",
      date_end: "2026-09-12T12:00:00Z",
      site: "https://example.org",
      online: true,
      organization_short_names: ["sao_paulo_klubo"]
    }

    result = Api::V2::Events::Create.call(user: @user, params:)

    assert result.failure?
    assert_match(/not a member/, result.error[:organization_short_names].first)
  end

  test "allows admin to attach any existing organization" do
    admin = users(:admin_user)
    params = {
      title: "Admin Org Event",
      description: "Description",
      date_start: "2026-09-12T10:00:00Z",
      date_end: "2026-09-12T12:00:00Z",
      site: "https://example.org",
      online: true,
      organization_short_names: ["tokyo_society"]
    }

    result = Api::V2::Events::Create.call(user: admin, params:)

    assert result.success?
    assert_equal ["tokyo_society"], result.payload.organizations.pluck(:short_name)
  end

  test "fails when passing automatic time tag or unknown tag" do
    params = {
      title: "Bad Tag Event",
      description: "Description",
      date_start: "2026-09-12T10:00:00Z",
      date_end: "2026-09-12T12:00:00Z",
      site: "https://example.org",
      online: true,
      tags: ["Unutaga", "NonExistent"]
    }

    result = Api::V2::Events::Create.call(user: @user, params:)

    assert result.failure?
    assert_match(/invalid tags/, result.error[:tags].first)
  end

  private

  # Asserts that the given value matches standard UUID format.
  #
  # @param uuid [String, nil] UUID string to validate
  #
  # @return [void]
  def assert_present_uuid(uuid)
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i, uuid.to_s)
  end
end
