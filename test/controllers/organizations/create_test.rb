require "test_helper"

class OrganizationsController::CreateTest < ActionDispatch::IntegrationTest
  test "should create organization" do
    user = users(:user)
    sign_in user

    country = Country.first || Country.create!(code: "xx", name_eo: "Test", name_en: "Test", name_fr: "Test")

    assert_difference(["Organization.count", "OrganizationUser.count"]) do
      post organizations_url, params: {
        organization: {
          name: "Nova Organizo",
          short_name: "nova",
          country_id: country.id
        }
      }
    end

    assert_redirected_to organization_url(Organization.last.short_name)
    assert_equal "Organizo sukcese kreita.", flash[:notice]

    # Verify the user became an admin of the newly created organization
    org_user = OrganizationUser.last
    assert_equal user.id, org_user.user_id
    assert_equal Organization.last.id, org_user.organization_id
    assert_equal true, org_user.admin
  end

  test "should render new if validation fails" do
    user = users(:user)
    sign_in user

    country = Country.first || Country.create!(code: "xx", name_eo: "Test", name_en: "Test", name_fr: "Test")

    assert_no_difference(["Organization.count", "OrganizationUser.count"]) do
      post organizations_url, params: {
        organization: {
          short_name: "nova",
          country_id: country.id
          # Missing name triggers validation error
        }
      }
    end

    assert_response :success # renders new template
  end

  test "should redirect unauthenticated users" do
    country = Country.first || Country.create!(code: "xx", name_eo: "Test", name_en: "Test", name_fr: "Test")

    assert_no_difference(["Organization.count", "OrganizationUser.count"]) do
      post organizations_url, params: {
        organization: {
          name: "Nova Organizo",
          short_name: "nova",
          country_id: country.id
        }
      }
    end

    assert_response :redirect
  end
end
