require "test_helper"

class OrganizationsController::ForighuTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = create(:user)
    @normal_user = create(:user)
    @organization = create(:organization, users: [])
    OrganizationUser.create!(organization: @organization, user: @admin_user, admin: true)
    OrganizationUser.create!(organization: @organization, user: @normal_user, admin: false)
  end

  test "should remove user from organization using delete request" do
    sign_in @admin_user

    assert_difference "OrganizationUser.count", -1 do
      delete organization_forighu_url(@organization.short_name, @normal_user.username)
    end

    assert_redirected_to organization_url(@organization.short_name)
    assert_equal "Sukceso", flash[:success]
  end

  test "should not allow unauthorized user to remove user" do
    sign_in @normal_user

    assert_no_difference "OrganizationUser.count" do
      delete organization_forighu_url(@organization.short_name, @admin_user.username)
    end

    assert_redirected_to organizations_url
    assert_equal "Vi ne rajtas fari tion", flash[:error]
  end

  test "should not allow unauthenticated user to remove user" do
    assert_no_difference "OrganizationUser.count" do
      delete organization_forighu_url(@organization.short_name, @normal_user.username)
    end

    assert_redirected_to new_user_session_url
  end
end
