# frozen_string_literal: true

require "test_helper"

# Integration tests for {EventsController#create}.
class EventsController::CreateTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:teacher)
    @country = countries(:afghanistan)
  end

  # Success cases

  test "creates event with tags, organizations, format, notifications, tracking, and audit log" do
    sign_in @user
    org = organizations(:rotterdam_centre)
    category_tag = tags(:kurso)
    characteristic_tag = tags(:por_junuloj)

    assert_enqueued_with(job: NovaEventaSciigoJob) do
      assert_difference ["Event.count", "Log.count", "Ahoy::Event.count"], 1 do
        post events_path, params: {
          event: {
            title: "Web Created Event",
            description: "Created through the web form",
            date_start: "2027-05-10",
            date_end: "2027-05-12",
            time_zone: "Europe/Amsterdam",
            site: "https://example.org/web-event",
            email: "web@example.org",
            city: "Rotterdam",
            country_id: @country.id,
            online: false
          },
          time_start: "10:00",
          time_end: "18:00",
          tags_categories: [category_tag.id.to_s],
          tags_characteristics: [characteristic_tag.id.to_s],
          organization_ids: [org.id.to_s]
        }
      end
    end

    created_event = Event.order(:id).last
    assert_redirected_to event_path(code: created_event.ligilo)
    assert_equal I18n.t("flash.events.created"), flash[:notice]
    assert_equal "onsite", created_event.format
    assert_equal [org.id], created_event.organizations.pluck(:id)
    assert_includes created_event.tags, category_tag
    assert_includes created_event.tags, characteristic_tag
  end

  # Error cases

  test "re-renders new form when attributes are invalid" do
    sign_in @user

    assert_no_difference "Event.count" do
      post events_path, params: {
        event: {
          title: "",
          description: "",
          date_start: "2027-05-10",
          date_end: "2027-05-12",
          time_zone: "Etc/UTC",
          city: "Rotterdam",
          country_id: @country.id
        },
        time_start: "10:00",
        time_end: "18:00"
      }
    end

    assert_response :success
  end

  test "requires authentication" do
    post events_path, params: {event: {title: "Unauthenticated Event"}}

    assert_redirected_to new_user_session_path
  end
end
