require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:organization)
    get organizations_url
    assert_response :success
  end

  test "should get new" do
    user = create(:user)
    sign_in user

    get new_organization_url
    assert_response :success
  end
end
