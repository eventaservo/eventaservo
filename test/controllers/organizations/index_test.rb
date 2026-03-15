require "test_helper"

class OrganizationsController::IndexTest < ActionDispatch::IntegrationTest
  test "should get index" do
    create(:organization)
    get organizations_url
    assert_response :success
  end
end
