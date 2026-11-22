# frozen_string_literal: true

require "test_helper"

class Events::UpdateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionMailer::TestHelper

  setup do
    @owner = users(:user)
    @event = events(:valid_event)
    @event.tags << tags(:kurso) unless @event.tags.include?(tags(:kurso))
    @event.tags << tags(:por_junuloj) unless @event.tags.include?(tags(:por_junuloj))
    @event.organizations << organizations(:rotterdam_centre) unless @event.organizations.include?(organizations(:rotterdam_centre))
  end

  # Success cases

  test "updates event attributes, enqueues notification job, and logs update" do
    result = nil
    assert_enqueued_with(job: EventoGhisdatigitaJob) do
      assert_difference "Log.count", 1 do
        result = Events::Update.call(
          event: @event,
          user: @owner,
          attributes: {title: "Updated Conference Title"}
        )
      end
    end

    assert result.success?
    assert_equal "Updated Conference Title", result.payload.title
    assert_equal "onsite", result.payload.format

    log = Log.order(:id).last
    assert_equal "Event updated", log.text
    assert_equal @owner, log.user
    assert_equal @event, log.loggable
  end

  test "preserves existing organizations and tags when nil is passed" do
    result = Events::Update.call(
      event: @event,
      user: @owner,
      attributes: {description: "Updated description only"},
      tag_ids: nil,
      organization_ids: nil
    )

    assert result.success?
    assert_includes result.payload.tags, tags(:kurso)
    assert_includes result.payload.tags, tags(:por_junuloj)
    assert_includes result.payload.organizations, organizations(:rotterdam_centre)
  end

  test "synchronizes tags and organizations when arrays are provided while preserving time tags" do
    new_category = tags(:kunveno_evento)
    new_org = organizations(:sao_paulo_klubo)
    time_tag = tags(:plurtaga)
    @event.tags << time_tag unless @event.tags.include?(time_tag)

    result = Events::Update.call(
      event: @event,
      user: @owner,
      attributes: {title: "Resynced Event"},
      tag_ids: [new_category.id],
      organization_ids: [new_org.id]
    )

    assert result.success?
    assert_includes result.payload.tags, new_category
    assert_not_includes result.payload.tags, tags(:kurso)
    assert_not_includes result.payload.tags, tags(:por_junuloj)
    assert_includes result.payload.tags, time_tag
    assert_equal [new_org.id], result.payload.organizations.pluck(:id)
  end

  test "clears manageable tags and organizations when empty arrays are provided" do
    result = Events::Update.call(
      event: @event,
      user: @owner,
      attributes: {title: "Cleared Associations"},
      tag_ids: [],
      organization_ids: []
    )

    assert result.success?
    assert_empty result.payload.tags.where(group_name: %w[category characteristic])
    assert_empty result.payload.organizations
  end

  test "recomputes format when online and city change" do
    result = Events::Update.call(
      event: @event,
      user: @owner,
      attributes: {online: true, city: "Reta", country_id: 99_999}
    )

    assert result.success?
    assert_equal "online", result.payload.format
  end

  test "geocodes and refreshes timezone when address changes even if coordinates are unchanged" do
    @event.update_columns(latitude: 40.71, longitude: -74.00, time_zone: "Etc/UTC")

    result = Events::Update.call(
      event: @event,
      user: @owner,
      attributes: {address: "100 Broadway"}
    )

    assert result.success?
    assert_in_delta 40.71, result.payload.latitude
    assert_in_delta(-74.00, result.payload.longitude)
    assert_equal "America/New_York", result.payload.time_zone
  end

  test "sends nova_administranto email when event owner changes" do
    new_owner = users(:teacher)
    admin = users(:admin_user)

    assert_enqueued_emails 1 do
      result = Events::Update.call(
        event: @event,
        user: admin,
        attributes: {user_id: new_owner.id}
      )

      assert result.success?
      assert_equal new_owner, result.payload.user
    end
  end

  test "does not send nova_administranto email when owner does not change" do
    assert_enqueued_emails 0 do
      result = Events::Update.call(
        event: @event,
        user: @owner,
        attributes: {title: "Same Owner Title"}
      )

      assert result.success?
    end
  end

  test "allows organization member to update event" do
    member = users(:speaker)

    result = Events::Update.call(
      event: @event,
      user: member,
      attributes: {description: "Updated by org member"}
    )

    assert result.success?
    assert_equal "Updated by org member", result.payload.description
  end

  # Error cases

  test "returns forbidden when user is not authorized" do
    @event.organizations.clear
    unauthorized_user = users(:teacher)

    result = nil
    assert_no_enqueued_jobs(only: EventoGhisdatigitaJob) do
      assert_no_difference "Log.count" do
        result = Events::Update.call(
          event: @event,
          user: unauthorized_user,
          attributes: {title: "Unauthorized Edit"}
        )
      end
    end

    assert result.failure?
    assert_equal :forbidden, result.error
    assert_not_equal "Unauthorized Edit", @event.reload.title
  end

  test "fails with validation errors and event payload when attributes are invalid" do
    geocode_called = false
    timezone_called = false
    result = nil

    Geocoder.stub :search, ->(*_args) { geocode_called = true } do
      Timezone.stub :lookup, ->(*_args) { timezone_called = true } do
        assert_no_enqueued_jobs(only: EventoGhisdatigitaJob) do
          assert_no_difference "Log.count" do
            result = Events::Update.call(
              event: @event,
              user: @owner,
              attributes: {title: "", address: "New Invalid Street"}
            )
          end
        end
      end
    end

    assert result.failure?
    assert_not geocode_called
    assert_not timezone_called
    assert_includes result.error[:title], I18n.t("errors.messages.blank")
    assert_equal @event, result.payload
    assert_not_empty result.payload.errors[:title]
  end
end
