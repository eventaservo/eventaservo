# frozen_string_literal: true

require "test_helper"

class Admin::OrganizationsController::IndexTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @org = Organization.create!(name: "UEA", short_name: "uea", country: countries(:country_1))
  end

  test "should get index" do
    get admin_organizations_url
    assert_response :success
    assert_select "div", text: /#{@org.name}/
  end

  test "should filter by name" do
    get admin_organizations_url, params: {name_cont: @org.name}
    assert_response :success
    assert_select "div", text: /#{@org.name}/

    get admin_organizations_url, params: {name_cont: "Non-existent"}
    assert_response :success
    assert_select "div", text: /#{@org.name}/, count: 0
  end

  test "should deny access to non-admin" do
    sign_out @admin
    sign_in users(:user)
    get admin_organizations_url
    assert_redirected_to root_path
  end
end

class Admin::OrganizationsController::ShowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin_user)
    sign_in @admin
    @org = Organization.create!(name: "UEA", short_name: "uea", country: countries(:country_1))
  end

  test "should get show" do
    get admin_organization_url(@org)
    assert_response :success
    assert_select "h2", text: @org.name
  end

  test "should deny access to non-admin" do
    sign_out @admin
    sign_in users(:user)
    get admin_organization_url(@org)
    assert_redirected_to root_path
  end
end
