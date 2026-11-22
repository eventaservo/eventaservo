# frozen_string_literal: true

require "test_helper"

class Admin::OrganizationsController::DestroyTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    @source_org = organizations(:rotterdam_centre)
    @target_org = organizations(:sao_paulo_klubo)
    @event = events(:valid_event)
  end

  # Success cases

  test "deletes organization with events and transfers them to target organization" do
    @source_org.organization_events.create!(event: @event)
    sign_in @admin

    assert_difference "Organization.count", -1 do
      delete admin_organization_path(@source_org), params: {target_organization_id: @target_org.id}
    end

    assert_redirected_to admin_organizations_path
    assert_equal I18n.t("flash.admin.organizations.destroyed", name: @source_org.name), flash[:notice]
    assert_not Organization.exists?(@source_org.id)
    assert_includes @target_org.reload.events, @event
  end

  test "deletes organization without events when no target organization is given" do
    @source_org.organization_events.destroy_all
    sign_in @admin

    assert_difference "Organization.count", -1 do
      delete admin_organization_path(@source_org)
    end

    assert_redirected_to admin_organizations_path
    assert_not Organization.exists?(@source_org.id)
  end

  # Error cases

  test "renders delete page with unprocessable_entity when events exist and no target is selected" do
    @source_org.organization_events.create!(event: @event)
    sign_in @admin

    assert_no_difference "Organization.count" do
      delete admin_organization_path(@source_org)
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("flash.admin.organizations.target_required"), flash[:alert]
    assert Organization.exists?(@source_org.id)
  end

  test "denies access to non-admin users" do
    sign_in users(:user)

    assert_no_difference "Organization.count" do
      delete admin_organization_path(@source_org), params: {target_organization_id: @target_org.id}
    end

    assert_redirected_to root_path
  end

  test "redirects unauthenticated users to login" do
    assert_no_difference "Organization.count" do
      delete admin_organization_path(@source_org), params: {target_organization_id: @target_org.id}
    end

    assert_redirected_to new_user_session_path
  end
end
