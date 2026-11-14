# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for the event detail page, sidebar, dropdown, and responsive layout.
class EventDetailSystemTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "event detail page renders sidebar, add-to-calendar menu, and responsive layout" do
    event = events(:valid_event)

    visit event_path(code: event.ligilo)

    assert_selector "#evento", text: event.title
    assert_selector "#informoj", text: /#{I18n.t("events.details.header")}/i
    assert_selector "#partoprenantoj"

    find("#add-to-calendar-options").click
    assert_selector "#add-to-calendar-menu.show", visible: true
    assert_selector "#add-to-calendar-menu a", text: "Google"

    [375, 768, 1280].each do |width|
      page.current_window.resize_to(width, 900)
      scroll_width = evaluate_script("document.documentElement.scrollWidth")
      client_width = evaluate_script("document.documentElement.clientWidth")
      assert_operator scroll_width, :<=, client_width,
        "Expected no horizontal overflow at #{width}px on event detail page (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
    end
  end

  test "interested button toggles yes/no confirmation choices for signed-in users" do
    event = events(:valid_event)
    # Devise UI login requires a confirmed user with a known password hash (:e2e_test_user)
    login_as

    visit event_path(code: event.ligilo)

    find("[data-event-user-interested-button-target='button']").click
    assert_selector "[data-event-user-interested-button-target='question'] a", text: I18n.t("common.yes_upper"), visible: true
    assert_selector "[data-event-user-interested-button-target='question'] a", text: I18n.t("common.no_upper"), visible: true
  end

  test "owner can delete an uploaded image from event detail page" do
    user = create(:user, :e2e_test_user)
    event = events(:valid_event)
    event.update!(user:)
    event.uploads.attach(
      io: File.open(Rails.root.join("test/fixtures/files/jes.png")),
      filename: "jes.png",
      content_type: "image/png"
    )
    login_as(user)

    visit event_path(code: event.ligilo)
    assert_selector "#lightgallery .foto"

    accept_confirm do
      within("#lightgallery") { click_on I18n.t("buttons.delete") }
    end

    assert_text "Dosiero sukcese forigita"
    assert_no_selector "#lightgallery .foto"
    assert_not event.reload.uploads.attached?
  end
end
