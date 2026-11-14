# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for Tailwind-migrated event create/edit forms and video pages.
class EventFormsSystemTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "event create form toggles sections, category pills, and renders without overflow" do
    user = create(:user, :e2e_test_user)
    login_as(user)

    visit new_event_path
    assert_selector "h1", text: I18n.t("events.form.new_title")
    assert_text I18n.t("events.form.write_in_esperanto_notice")
    assert_no_horizontal_overflow(new_event_path)

    [375, 1280].each do |width|
      page.current_window.resize_to(width, 900)
      widths = evaluate_script(<<~JS)
        (() => {
          const fieldset = document.querySelector("#malretaj_informoj .hw-combobox");
          const wrapper = fieldset?.querySelector(".hw-combobox__main__wrapper");
          if (!fieldset || !wrapper) return null;
          return [fieldset.parentElement.getBoundingClientRect().width, wrapper.getBoundingClientRect().width];
        })()
      JS
      refute_nil widths
      parent_width, wrapper_width = widths
      assert_operator wrapper_width, :>=, parent_width - 2,
        "Expected country combobox wrapper (#{wrapper_width}px) to match column width (#{parent_width}px) at #{width}px"
    end

    # Online/universal sections toggle cleanly
    assert_no_selector "#retaj_informoj", visible: true
    find("#event_online").check
    assert_selector "#retaj_informoj", visible: true

    find("#universala").check
    assert_selector "#horzono", visible: true
    assert_no_selector "#malretaj_informoj", visible: true

    # Category pill toggles checked state and checkmark visibility
    category_tag = tags(:kunveno_evento)
    refute find("#tag_#{category_tag.id}", visible: :all).checked?
    assert_no_selector "label[for='tag_#{category_tag.id}'] i.fa-check", visible: true

    find("label[for='tag_#{category_tag.id}']").click
    assert find("#tag_#{category_tag.id}", visible: :all).checked?
    assert_selector "label[for='tag_#{category_tag.id}'] i.fa-check", visible: true
  end

  test "event edit form checks short url availability, opens cancel modal, and has no overflow" do
    user = create(:user, :e2e_test_user)
    event = events(:valid_event)
    event.update!(user:)

    other_event = events(:esperanto_meetup)
    other_event.update!(short_url: "esperanto-meetup")

    login_as(user)

    visit edit_event_path(code: event.ligilo)
    assert_selector "h1", text: I18n.t("buttons.edit")
    assert_no_horizontal_overflow(edit_event_path(code: event.ligilo))

    # Blur triggers short-url Turbo Stream availability check
    short_url_input = find("#event_short_url")
    short_url_input.fill_in with: other_event.short_url
    find("h1").click
    assert_selector "#short_url_availability", text: I18n.t("events.form.short_url_unavailable")

    # Cancel event <dialog> modal opens and closes cleanly
    find("[data-dialog-open='nuligiloModal']").click
    assert_selector "dialog#nuligiloModal[open]"
    click_on I18n.t("buttons.close")
    assert_no_selector "dialog#nuligiloModal[open]"
  end

  test "video index and new video form render without overflow and toggle thumbnail field" do
    user = create(:user, :e2e_test_user)
    event = events(:valid_event)
    event.update!(user:)
    login_as(user)

    visit video_path
    assert_selector "#evento", text: I18n.t("video.presentations")
    assert_text videos(:rails_conference_video).title
    assert_no_horizontal_overflow(video_path)

    new_video_path = event_nova_video_path(event_code: event.ligilo)
    visit new_video_path
    assert_selector "h1", text: "Ligi registritan prezenton"
    assert_no_horizontal_overflow(new_video_path)

    # YouTube URL hides manual thumbnail upload via Stimulus tw:hidden
    assert_selector "#thumbnail", visible: true
    find("#video_link").fill_in with: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    find("h1").click
    assert_no_selector "#thumbnail", visible: true

    # Non-YouTube URL restores manual thumbnail upload visibility
    find("#video_link").fill_in with: "https://vimeo.com/123456"
    find("h1").click
    assert_selector "#thumbnail", visible: true
  end

  private

  # Asserts that the page at +path+ renders without horizontal overflow across key viewports.
  #
  # @param path [String] the visited URL path for failure context
  # @return [void]
  def assert_no_horizontal_overflow(path)
    [375, 768, 1280].each do |width|
      page.current_window.resize_to(width, 900)
      scroll_width = evaluate_script("document.documentElement.scrollWidth")
      client_width = evaluate_script("document.documentElement.clientWidth")
      assert_operator scroll_width, :<=, client_width,
        "Expected no horizontal overflow at #{width}px on #{path} (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
    end
  end
end
