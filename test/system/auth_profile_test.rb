# frozen_string_literal: true

require "application_system_test_case"

# End-to-end tests for Tailwind-migrated Devise auth pages, profile edit form, and user profiles.
class AuthProfileSystemTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "devise auth pages render without horizontal overflow across viewports" do
    [
      new_user_session_path,
      new_user_registration_path,
      new_user_password_path,
      new_user_confirmation_path
    ].each do |path|
      visit path
      assert_text "Eventa Servo"

      [375, 768, 1280].each do |width|
        page.current_window.resize_to(width, 900)
        scroll_width = evaluate_script("document.documentElement.scrollWidth")
        client_width = evaluate_script("document.documentElement.clientWidth")
        assert_operator scroll_width, :<=, client_width,
          "Expected no horizontal overflow at #{width}px on #{path} (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
      end
    end
  end

  test "signed-in user can toggle teacher details in profile edit and view profile pages without overflow" do
    # Devise UI login requires a confirmed user with the :e2e_test_user password hash
    user = create(:user, :e2e_test_user)
    login_as(user)

    visit edit_user_registration_path
    assert_selector "#profilo h2", text: I18n.t("devise.registrations.edit.title")
    assert_selector "#instruisto-details.tw\\:hidden", visible: :all

    find("[data-user-target='instruisto']").click
    assert_selector "#instruisto-details", visible: true
    assert_no_selector "#instruisto-details.tw\\:hidden", visible: :all

    visit events_by_username_path(username: user.username)
    assert_selector "h1", text: user.name
    find("a[data-dialog-open='webcalModal']").click
    assert_selector "dialog#webcalModal[open]"
    click_on I18n.t("buttons.close")
    assert_no_selector "dialog#webcalModal[open]"

    teacher = users(:teacher)
    [
      events_by_username_path(username: teacher.username),
      user_events_path(username: user.username)
    ].each do |path|
      visit path
      [375, 768, 1280].each do |width|
        page.current_window.resize_to(width, 900)
        scroll_width = evaluate_script("document.documentElement.scrollWidth")
        client_width = evaluate_script("document.documentElement.clientWidth")
        assert_operator scroll_width, :<=, client_width,
          "Expected no horizontal overflow at #{width}px on #{path} (scrollWidth=#{scroll_width}, clientWidth=#{client_width})"
      end
    end
  end
end
