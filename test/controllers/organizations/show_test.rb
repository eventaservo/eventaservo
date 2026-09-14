require "test_helper"

class OrganizationsController::ShowTest < ActionDispatch::IntegrationTest
  test "should get show" do
    organization = create(:organization)
    get organization_url(organization.short_name)
    assert_response :success
  end

  test "should render phone link when organization has phone" do
    organization = create(:organization, phone: "+55 11 99999-9999")
    get organization_url(organization.short_name)
    assert_response :success
    assert_select "a[href='tel:+55 11 99999-9999']", text: "+55 11 99999-9999"
  end
end
