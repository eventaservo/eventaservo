# frozen_string_literal: true

require "test_helper"

class Events::KronologioQueryTest < ActiveSupport::TestCase
  setup do
    @event = events(:valid_event)
    @other_event = events(:esperanto_meetup)
    @user = users(:user)
    @admin = users(:admin_user)
    @afghanistan = countries(:afghanistan)
    @albania = countries(:albania)
  end

  test "returns empty collections when event has no versions" do
    result = Events::KronologioQuery.new(event: @event).call

    assert_empty result[:versions]
    assert_empty result[:users_cache]
    assert_empty result[:countries_cache]
  end

  test "returns event versions ordered newest first with joined user_name" do
    older = PaperTrail::Version.create!(
      item_type: "Event",
      item_id: @event.id,
      event: "update",
      whodunnit: @user.id.to_s,
      object_changes: {title: ["Old Title", "Mid Title"]},
      created_at: 2.hours.ago
    )
    newer = PaperTrail::Version.create!(
      item_type: "Event",
      item_id: @event.id,
      event: "update",
      whodunnit: nil,
      object_changes: {title: ["Mid Title", "New Title"]},
      created_at: 1.hour.ago
    )

    result = Events::KronologioQuery.new(event: @event).call

    assert_equal [newer.id, older.id], result[:versions].map(&:id)
    assert_nil result[:versions].first.user_name
    assert_equal @user.name, result[:versions].last.user_name
  end

  test "includes ActionText::RichText versions for event enhavo" do
    @event.update!(enhavo: "<p>Original body</p>")
    rich_text_version = PaperTrail::Version.create!(
      item_type: "ActionText::RichText",
      item_id: @event.rich_text_enhavo.id,
      event: "update",
      whodunnit: @admin.id.to_s,
      object_changes: {body: ["<p>Original body</p>", "<p>Updated body</p>"]}
    )

    result = Events::KronologioQuery.new(event: @event).call

    assert_includes result[:versions].map(&:id), rich_text_version.id
    matched = result[:versions].find { |v| v.id == rich_text_version.id }
    assert_equal @admin.name, matched.user_name
  end

  test "excludes versions belonging to other events" do
    own_version = PaperTrail::Version.create!(
      item_type: "Event",
      item_id: @event.id,
      event: "update",
      object_changes: {title: ["A", "B"]}
    )
    other_version = PaperTrail::Version.create!(
      item_type: "Event",
      item_id: @other_event.id,
      event: "update",
      object_changes: {title: ["C", "D"]}
    )

    result = Events::KronologioQuery.new(event: @event).call

    assert_includes result[:versions].map(&:id), own_version.id
    assert_not_includes result[:versions].map(&:id), other_version.id
  end

  test "preloads users_cache and countries_cache from user_id and country_id changesets" do
    PaperTrail::Version.create!(
      item_type: "Event",
      item_id: @event.id,
      event: "update",
      object_changes: {
        user_id: [@user.id, @admin.id],
        country_id: [@afghanistan.id, @albania.id],
        participants_count: [0, 5]
      }
    )

    result = Events::KronologioQuery.new(event: @event).call

    assert_equal({@user.id => @user, @admin.id => @admin}, result[:users_cache])
    assert_equal({@afghanistan.id => @afghanistan, @albania.id => @albania}, result[:countries_cache])
  end

  test "respects the limit option" do
    3.times do |i|
      PaperTrail::Version.create!(
        item_type: "Event",
        item_id: @event.id,
        event: "update",
        object_changes: {title: ["Title #{i}", "Title #{i + 1}"]},
        created_at: (3 - i).hours.ago
      )
    end

    result = Events::KronologioQuery.new(event: @event, limit: 2).call

    assert_equal 2, result[:versions].size
  end
end
