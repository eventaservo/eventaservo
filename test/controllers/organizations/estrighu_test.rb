require "test_helper"

class OrganizationsController::EstrighuTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = create(:user)
    @normal_user = create(:user)
    @organization = create(:organization, users: [])
    OrganizationUser.create!(organization: @organization, user: @admin_user, admin: true)
    OrganizationUser.create!(organization: @organization, user: @normal_user, admin: false)
  end

  test "should toggle admin status using patch request" do
    sign_in @admin_user
    ou = OrganizationUser.find_by(organization: @organization, user: @normal_user)
    assert_not ou.admin?

    patch organization_estrighu_url(@organization.short_name, @normal_user.username)

    assert_redirected_to organization_url(@organization.short_name)
    assert_equal "Sukceso", flash[:success]
    assert ou.reload.admin?

    patch organization_estrighu_url(@organization.short_name, @normal_user.username)
    assert_not ou.reload.admin?
  end

  test "should not allow unauthorized user to toggle admin status" do
    sign_in @normal_user

    patch organization_estrighu_url(@organization.short_name, @admin_user.username)

    assert_redirected_to organizations_url
    assert_equal "Vi ne rajtas fari tion", flash[:error]
    assert OrganizationUser.find_by(organization: @organization, user: @admin_user).admin?
  end

  test "should not allow unauthenticated user to toggle admin status" do
    patch organization_estrighu_url(@organization.short_name, @normal_user.username)

    assert_redirected_to new_user_session_url
  end
end
