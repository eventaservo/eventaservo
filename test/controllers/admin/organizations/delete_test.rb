# frozen_string_literal: true

require "test_helper"

class Admin::OrganizationsController::DeleteTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @org = organizations(:rotterdam_centre)
  end

  # Success cases

  test "renders delete confirmation page with target selector when organization has events" do
    @org.organization_events.create!(event: events(:valid_event))
    sign_in @admin

    get delete_admin_organization_path(@org)

    assert_response :success
    assert_select "h1", text: /#{Regexp.escape(@org.name)}/
    assert_select "select[name='target_organization_id']"
  end

  test "renders delete confirmation page without target selector when organization has no events" do
    @org.organization_events.destroy_all
    sign_in @admin

    get delete_admin_organization_path(@org)

    assert_response :success
    assert_select "h1", text: /#{Regexp.escape(@org.name)}/
    assert_select "select[name='target_organization_id']", count: 0
  end

  # Error cases

  test "redirects with alert when organization is not found" do
    sign_in @admin

    get delete_admin_organization_path("nonexistent_org_slug")

    assert_redirected_to admin_organizations_path
    assert_equal I18n.t("flash.admin.organizations.not_found"), flash[:alert]
  end

  test "denies access to non-admin users" do
    sign_in users(:user)

    get delete_admin_organization_path(@org)

    assert_redirected_to root_path
  end

  test "redirects unauthenticated users to login" do
    get delete_admin_organization_path(@org)

    assert_redirected_to new_user_session_path
  end
end
