# frozen_string_literal: true

require "test_helper"

class Events::CreateTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users(:teacher)
    @country = countries(:afghanistan)
    @base_attributes = {
      title: "Esperanto Congress",
      description: "Annual gathering of Esperantists",
      date_start: 1.month.from_now.change(usec: 0),
      date_end: (1.month.from_now + 2.days).change(usec: 0),
      time_zone: "Europe/Amsterdam",
      site: "https://example.org/congress",
      email: "info@example.org",
      city: "Rotterdam",
      country_id: @country.id,
      online: false
    }
  end

  # Success cases

  test "creates onsite event with tags, organizations, format, notification job, and audit log" do
    org = organizations(:rotterdam_centre)
    category_tag = tags(:kurso)
    characteristic_tag = tags(:por_junuloj)

    result = nil
    assert_enqueued_with(job: NovaEventaSciigoJob) do
      assert_difference ["Event.count", "Log.count"], 1 do
        result = Events::Create.call(
          user: @user,
          attributes: @base_attributes,
          tag_ids: [category_tag.id, characteristic_tag.id],
          organization_ids: [org.id]
        )
      end
    end

    assert result.success?
    event = result.payload
    assert event.persisted?
    assert_equal @user, event.user
    assert_equal "onsite", event.format
    assert_equal [org.id], event.organizations.pluck(:id)
    assert_includes event.tags, category_tag
    assert_includes event.tags, characteristic_tag

    log = Log.order(:id).last
    assert_equal "Event created", log.text
    assert_equal @user, log.user
    assert_equal event, log.loggable
  end

  test "computes online format when event is online with city Reta" do
    result = Events::Create.call(
      user: @user,
      attributes: @base_attributes.merge(online: true, city: "Reta", country_id: 99_999)
    )

    assert result.success?
    assert_equal "online", result.payload.format
  end

  test "computes hybrid format when event is online with a physical city" do
    result = Events::Create.call(
      user: @user,
      attributes: @base_attributes.merge(online: true, city: "Rotterdam")
    )

    assert result.success?
    assert_equal "hybrid", result.payload.format
  end

  test "preserves explicit user_id in attributes when provided" do
    owner = users(:user)

    result = Events::Create.call(
      user: users(:admin_user),
      attributes: @base_attributes.merge(user_id: owner.id)
    )

    assert result.success?
    assert_equal owner, result.payload.user
    assert_equal users(:admin_user), Log.order(:id).last.user
  end

  test "ignores time tags passed in tag_ids" do
    time_tag = tags(:unutaga)
    category_tag = tags(:kurso)

    result = Events::Create.call(
      user: @user,
      attributes: @base_attributes,
      tag_ids: [category_tag.id, time_tag.id]
    )

    assert result.success?
    assert_includes result.payload.tags, category_tag
    assert_not_includes result.payload.tags, time_tag
  end

  # Error cases

  test "fails with validation errors and unsaved event payload when attributes are invalid" do
    result = nil
    assert_no_enqueued_jobs(only: NovaEventaSciigoJob) do
      assert_no_difference ["Event.count", "Log.count"] do
        result = Events::Create.call(
          user: @user,
          attributes: @base_attributes.merge(title: "")
        )
      end
    end

    assert result.failure?
    assert_includes result.error[:title], I18n.t("errors.messages.blank")
    assert_instance_of Event, result.payload
    assert_not result.payload.persisted?
    assert_not_empty result.payload.errors[:title]
  end
end
