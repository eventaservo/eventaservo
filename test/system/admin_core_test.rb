# frozen_string_literal: true

require "application_system_test_case"

class AdminCoreTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
    @admin = create(:user, :admin, :e2e_test_user)
    login_as(@admin)
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "admin core pages render cleanly with breadcrumbs and without horizontal overflow" do
    visit admin_root_path
    assert_selector "h1", text: "Admin Panel"
    assert_no_horizontal_overflow(admin_root_path)

    [
      [admin_events_path, "Ĉiuj eventoj", "Events"],
      [admin_logs_path, "Logs", "Logs"],
      [admin_organizations_path, "Ĉiuj organizaĵoj", "Organizaĵoj"],
      [admin_statistics_path, "Statistikoj", "Statistikoj"]
    ].each do |path, heading, crumb|
      visit path
      assert_selector "nav[aria-label='breadcrumb']", text: "Admin"
      assert_selector "nav[aria-label='breadcrumb'] [aria-current='page']", text: crumb
      assert_selector "h1", text: heading
      assert_no_horizontal_overflow(path)
    end
  end

  private

  # Asserts that the page at +path+ renders without horizontal overflow across mobile, tablet, and desktop.
  #
  # @param path [String] visited URL path for assertion failure context
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
