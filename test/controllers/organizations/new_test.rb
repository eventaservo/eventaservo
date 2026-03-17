require "test_helper"

class OrganizationsController::NewTest < ActionDispatch::IntegrationTest
  test "should get new" do
    user = users(:user)
    sign_in user

    get new_organization_url
    assert_response :success
  end
end
