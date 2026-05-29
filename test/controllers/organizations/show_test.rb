require "test_helper"

class OrganizationsController::ShowTest < ActionDispatch::IntegrationTest
  test "should get show" do
    organization = create(:organization)
    get organization_url(organization.short_name)
    assert_response :success
  end
end
