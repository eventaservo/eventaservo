# frozen_string_literal: true

require "application_system_test_case"

# Checks admin users, reports, redirections, and reklamoj pages for breadcrumbs,
# headings, and horizontal overflow across mobile, tablet, and desktop widths.
class AdminManagementTest < ApplicationSystemTestCase
  setup do
    @original_window_size = page.current_window.size
    @admin = create(:user, :admin, :e2e_test_user)
    @target_user = users(:user)
    @report = create(:event_report)
    @redirection = EventRedirection.create!(old_short_url: "admin-mgmt-old", new_short_url: "admin-mgmt-new")
    login_as(@admin)
  end

  teardown do
    page.current_window.resize_to(*@original_window_size) if @original_window_size
  end

  test "admin management pages render cleanly with breadcrumbs and without horizontal overflow" do
    [
      [admin_users_path, "Users", "Users"],
      [admin_user_path(@target_user), @target_user.name, @target_user.name],
      [edit_admin_user_path(@target_user), "Edit User", "Edit"],
      [merge_admin_user_path(@target_user), "Merge Users", "Merge"],
      [admin_reports_path, "Eventaj Raportoj", "Raportoj"],
      [admin_report_path(@report), "Raportaj Detaloj", "Detaloj"],
      [edit_admin_report_path(@report), "Redakti Raporton", "Redakti"],
      [admin_redirections_path, "Eventaj Redirektoj", "Redirektoj"],
      [new_admin_redirection_path, "Nova Redirekto", "Nova"],
      [edit_admin_redirection_path(@redirection), "Redakti Redirekton", "Redakti"],
      [admin_reklamoj_index_path, "Reklamoj", "Reklamoj"],
      [new_admin_reklamoj_path, "Krei novan reklamon", "Nova"]
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
