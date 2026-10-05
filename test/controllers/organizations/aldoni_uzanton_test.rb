require "test_helper"

class OrganizationsController::AldoniUzantonTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = create(:user)
    @normal_user = create(:user)
    @target_user = create(:user)
    @organization = create(:organization, users: [])
    OrganizationUser.create!(organization: @organization, user: @admin_user, admin: true)
  end

  test "should allow admin user to add another user to organization" do
    sign_in @admin_user

    assert_difference("OrganizationUser.count", 1) do
      post organization_aldoni_uzanton_url(@organization.short_name), params: {id: @target_user.id}
    end

    assert_redirected_to organization_url(@organization.short_name)
    assert_equal "Uzanto aldonita al la organizo", flash[:success]
    assert OrganizationUser.find_by(organization: @organization, user: @target_user)
  end

  test "should not allow normal user to add another user to organization" do
    sign_in @normal_user

    assert_no_difference("OrganizationUser.count") do
      post organization_aldoni_uzanton_url(@organization.short_name), params: {id: @target_user.id}
    end

    assert_redirected_to organizations_url
    assert_equal "Vi ne rajtas fari tion", flash[:error]
  end

  test "should redirect unauthenticated user" do
    assert_no_difference("OrganizationUser.count") do
      post organization_aldoni_uzanton_url(@organization.short_name), params: {id: @target_user.id}
    end

    assert_redirected_to new_user_session_url
  end
end
